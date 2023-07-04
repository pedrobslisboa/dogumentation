#!/usr/bin/env node

const webpack = require("webpack");
const WebpackDevServer = require("webpack-dev-server");
const fs = require("fs");
const path = require("path");
const os = require("os");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const child_process = require("child_process");
const glob = require("glob");

const toAbsolutePath = (filepath) => {
  if (path.isAbsolute(filepath)) {
    return filepath;
  } else {
    return path.join(process.cwd(), filepath);
  }
};

const task = process.argv[2];

if (task !== "build" && task !== "start") {
  console.error(
    "You need to pass 'start' or 'build' command and path to the entry point.\nFor example: dogumentation start --entry=./example/Demo.bs.js"
  );
  process.exit(1);
}

// Servers can handle paths to HTML files differently.
// Allow using full path to HTML template in "src" attribute of iframe in case of possible issues.
const useFullframeUrl = (() => {
  const prefix = `--full-iframe-url=`;
  const arg = process.argv.find((item) => item.startsWith(prefix));
  if (arg === undefined) {
    return false;
  } else {
    const value = arg.replace(prefix, "");
    if (value === "true") {
      return true;
    } else {
      return false;
    }
  }
})();

const isBuild = task === "build";

const outputPath = (() => {
  if (isBuild) {
    return toAbsolutePath("./.dog");
  } else {
    return os.tmpdir();
  }
})();

let config = {
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|ico)$/i,
        use: [
          {
            loader: "file-loader",
          },
        ],
      },
      {
        test: /\.mdx?$/,
        use: [
          {
            loader: "@mdx-js/loader",
            /** @type {import('@mdx-js/loader').Options} */
            options: {
              
            },
          },
        ],
      },
      {
        test: /\.svg$/,
        use: [
          {
            loader: "react-svg-loader",
          },
        ],
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
};

try {
  const customConfig = require(path.join(
    process.cwd(),
    ".dogumentation/config.js"
  ));
  config = {
    ...config,
    ...customConfig,
  };
} catch (err) {
  // noop
}

const docBuildFolder = (() => {
  let docBuildFolder;
  if (isBuild) {
    docBuildFolder = path.join(process.cwd(), ".dog");
  } else {
    docBuildFolder = path.join(os.tmpdir(), ".dog");
  }

  if (!fs.existsSync(docBuildFolder)) {
    fs.mkdirSync(docBuildFolder);
  }

  return docBuildFolder;
})();

const entrypointPath = `${docBuildFolder}/entrypoint.js`;

const addDocToGitIgnore = () => {
  const gitIgnorePath = path.join(process.cwd(), ".gitignore");

  if (!fs.existsSync(gitIgnorePath)) {
    fs.writeFileSync(gitIgnorePath, docBuildFolder);
  } else {
    const gitIgnoreContent = fs.readFileSync(gitIgnorePath, "utf8");

    if (!gitIgnoreContent.includes(docBuildFolder)) {
      fs.appendFileSync(gitIgnorePath, "\n# Dogumentation build folder\n.dog");
    }
  }
};

const copyRescriptDocs = () => {
  const rescriptDocsFiles = [];

  glob
    .sync("**/*_dog.*.js", {
      ignore: ["**/lib/**", "**/.dog/**", "**/node_modules/**"],
    })
    .forEach(function (file) {
      rescriptDocsFiles.push(file);
    });

  const importData = rescriptDocsFiles.reduce((acc, file) => {
    acc += `import "${path.join(process.cwd())}/${file}";\n`;
    return acc;
  }, "");

  try {
    fs.writeFileSync(entrypointPath, importData);
    const mainFile = glob.sync("**/.dogumentation/Main.*.js")[0];

    if (!mainFile) {
      fs.appendFileSync(
        entrypointPath,
        `import * as Dogumentation from "${process.cwd()}/node_modules/dogumentation/src/Config.bs.js";\nDogumentation.start();`
      );
    } else {
      fs.appendFileSync(
        entrypointPath,
        `import "${process.cwd()}/${mainFile}";\n`
      );
    }
  } catch (err) {
    console.error(err);
  }
};

copyRescriptDocs();

const compiler = webpack({
  target: "web",
  mode: isBuild ? "production" : "development",
  entry: entrypointPath,
  output: {
    path: outputPath,
    filename: "dogumentation[fullhash].js",
    globalObject: "this",
    chunkLoadingGlobal: "dogumentation__d",
  },
  module: config.module,
  plugins: [
    ...(config.plugins ? config.plugins : []),
    new CopyWebpackPlugin({
      patterns: [{ from: path.join(__dirname, "../src/favicon.ico"), to: "" }],
    }),
    new HtmlWebpackPlugin({
      filename: "index.html",
      template: path.join(__dirname, "../src/ui-template.html"),
    }),
    new HtmlWebpackPlugin({
      filename: "./demo/index.html",
      template: process.argv.find((item) => item.startsWith("--template="))
        ? path.join(
            process.cwd(),
            process.argv
              .find((item) => item.startsWith("--template="))
              .replace(/--template=/, "")
          )
        : path.join(__dirname, "../src/demo-template.html"),
    }),
    new webpack.DefinePlugin({
      USE_FULL_IFRAME_URL: JSON.stringify(useFullframeUrl),
    }),
  ],
});

if (isBuild) {
  console.log("Building dogumentation bundle...");
  compiler.run((err, _result) => {
    if (err) {
      console.error(err);
    } else {
      console.log("Build finished.");
    }
  });
} else {
  const port = parseInt(
    process.argv.find((item) => item.startsWith("--port="))
      ? process.argv
          .find((item) => item.startsWith("--port="))
          .replace(/--port=/, "")
      : 9000,
    10
  );

  const server = new WebpackDevServer(compiler, {
    compress: true,
    port: port,
    publicPath: "/",
    historyApiFallback: {
      index: "/index.html",
    },
    stats: "errors-only",
    ...(config.devServer || {}),
  });

  ["SIGINT", "SIGTERM"].forEach((signal) => {
    process.on(signal, () => {
      if (server) {
        server.close(() => {
          process.exit();
        });
      } else {
        process.exit();
      }
    });
  });

  if (config.devServer && config.devServer.socket) {
    server.listen(config.devServer.socket);
  } else {
    server.listen(port, "0.0.0.0");
    child_process.exec("open http://localhost:" + port, () => {});
  }
}
