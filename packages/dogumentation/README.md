<h1 align="center">
  <img src="./logo.png" alt="Dogumentation" width="400" />  
</h1>

<p align="center">Build a do<s>g</s>cumentation for you Rescript React components</p>
<p align="center">This is a project forked and strongly inspired by <a href="https://github.com/bloodyowl/reshowcase">Reshowcase</a>
please check it out and also fund the author <a href="https://github.com/bloodyowl">bloodyowl</a> if you can.
</p>

## Table of Contents

- [Introduction](#introduction)
- [Install](#install)
- [Usage](#usage)
- [Configure](#configure)
- [Roadmap](#roadmap)

## Install

```console
yarn add --dev dogumentation
```

Then add to your `"dogumentation"` to `bs-dependencies` in your `bsconfig.json`.

## Usage

### Creating your Doguments

Create a file with de suffix `_dog.res`. Then create you Dogumentation as the exemple below:

```rescript
// Button_dog.res
open Dogumentation.Dog

addToCategory("Button", ({addDog}) => {
  addDog("Basic", controls => {
    let disabled = controls.bool("Disabled", false)
    <button
      disabled
      style={ReactDOM.Style.make(
        ~backgroundColor=controls.string(
          "Color",
          ~options=[("Red", "#E02020"), ("Green", "#6DD400"), ("Blue", "#0091FF")],
          "#0091FF",
        ),
        ~color="#fff",
        ~border="none",
        ~padding="10px",
        ~borderRadius="10px",
        ~fontFamily="inherit",
        ~fontSize="inherit",
        ~opacity=disabled ? "0.5" : "1",
        ~cursor=disabled ? "default" : "pointer",
        (),
      )}>
      {controls.string("Text", "hello")->React.string}
    </button>
  })

  addDog("Huge", ({string, bool}) => {
    let disabled = bool("Disabled", false)
    <button
      disabled
      style={ReactDOM.Style.make(
        ~backgroundColor=string(
          "Color",
          ~options=[("Red", "#E02020"), ("Green", "#6DD400"), ("Blue", "#0091FF")],
          "#0091FF",
        ),
        ~color="#fff",
        ~border="none",
        ~padding="20px",
        ~borderRadius="10px",
        ~fontFamily="inherit",
        ~fontSize="30px",
        ~opacity=disabled ? "0.5" : "1",
        ~cursor=disabled ? "default" : "pointer",
        (),
      )}>
      {string("Text", "Hello")->React.string}
    </button>
  })
})
```

### To start / develop:

```console
$ dogumentation start
```

### To build bundle:

```console
$ dogumentation build
```

It outputs the bundle to `./dog` folder.

If you need custom webpack options, create the `.dogumentation/config.js` and export the webpack config, plugins and modules will be merged.

If you need a custom template for your dogs, pass `--template=./path/to/template.html`.

## Configure

This is a plug and play library, but you can customize it.

Create a `Main.res` file on the `.dogumentation` folder, this file will be the entry point for the dogumentation.

Then call the start function from `Dogumentation.Config` module.

```rescript
open Dogumentation.Config

start()
```

### Customizing

To customize the dogumentation pass the config values to the `start` function.

```rescript
open Dogumentation.Config

@module("./logo.png")
external logo: string = "default"

module Intro = {
  @react.component
  let make = () => {
    <div>
      <h1> {"Sample Intro Documentation"->React.string} </h1>
      <p> {"Using Dogumentation you can create an easy rescript documentation."->React.string} </p>
      <h2> {"Usage:"->React.string} </h2>
      <p> {"Check out the sidebar to learn more"->React.string} </p>
    </div>
  }
}

let sortDogs = ((a, entity), (b, _)) => {
  switch entity {
  | Dogumentation.Entity.Demo(_) =>
    if a == "Basic" {
      -1
    } else if b == "Basic" {
      1
    } else {
      String.compare(a, b)
    }
  | Dogumentation.Entity.Category(_) =>
    if a == "Typography" {
      -1
    } else if b == "Typography" {
      1
    } else {
      String.compare(a, b)
    }
  }
}

let config: config = {
  intro: <Intro />,
  sortDogs,
  logo,
  decorators: [
    (dog, _) => {
      <div>
        {dog}
      </div>
    },
  ],
}

start(~config, ())
```

## Roadmap

- [ ] Decorators for categories
- [ ] Props available on decorators
- [ ] Tests
- [ ] Faster bundler
- [ ] CSS in JS support
- [ ] MDX support