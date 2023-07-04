export function highlightLinesCode(code, options) {
  if (code.querySelector(".highlight-line")) {
    return;
  }
  code.innerHTML = code.innerHTML.replace(
    /([ \S]*\n|[ \S]*$)/gm,
    function (match) {
      return '<div class="highlight-line">' + match + "</div>";
    }
  );

  if (options === undefined) {
    return;
  }

  const lines = code.querySelectorAll(".highlight-line");
  for (let option of options) {
    for (let j = option.start; j <= option.end; ++j) {
      lines[j].style.backgroundColor = option.color;
    }
  }
}
