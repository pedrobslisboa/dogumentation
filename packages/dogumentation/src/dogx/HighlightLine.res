@get
external innerHTML: Dom.element => string = "innerHTML"
@get
external style: Dom.element => Dom.htmlStyleElement = "style"
@set
external backgroundColor: (Dom.htmlStyleElement, string) => string = "backgroundColor"
@set
external setInnerHTML: (Dom.element, string) => string = "innerHTML"
@val external document: Dom.element = "document"
@send
external querySelectorAll: (Dom.element, string) => Js.Nullable.t<array<Dom.element>> =
  "querySelectorAll"
@send
external querySelector: (Dom.element, string) => Js.Nullable.t<Dom.element> = "querySelector"

type highlightLinesOption = {
  start: int,
  end?: int,
  color: string,
}

let highlightLinesCode = (code, options) => {
  switch code->querySelector(".highlight-line")->Js.Nullable.toOption {
  | Some(_) => Js.log(code->querySelector(".highlight-line"))
  | _ => {
      let _ = code->setInnerHTML(
        code
        ->innerHTML
        ->Js.String.unsafeReplaceBy0(
          %re("/([ \S]*\n|[ \S]*$)/gm"),
          (match, _, _) => {
            `<div class="highlight-line"> ${match}</div>`
          },
          _,
        ),
      )

      let _ =
        code
        ->querySelectorAll(".highlight-line")
        ->Js.Nullable.toOption
        ->Belt.Option.map(lines => {
          options->Belt.Array.forEach(option => {
            let end = option.end->Belt.Option.getWithDefault(option.start)

            for j in option.start to end {
              let _ = lines[j]->style->backgroundColor(option.color)
            }
          })
        })
    }
  }
}
