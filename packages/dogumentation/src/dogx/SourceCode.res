%%raw(`
  let hljs = require('highlight.js/lib/core');
  let rescript = require('./rescript-highlightjs');

  hljs.registerLanguage('rescript', rescript);
`)

type options = {language: string}

@deriving(abstract)
type highlightResult = {value: string}

@module("highlight.js/lib/core")
external highlight: (~code: string, ~options: options) => highlightResult = "highlight"
@val external document: Dom.element = "document"
@send
external querySelector: (Dom.element, string) => option<Dom.element> = "querySelector"

%%raw("import './_hljs.css'")

module CopyButton = {
  let copyToClipboard: string => bool = %raw(j`
  function(str) {
    try {
      const el = document.createElement('textarea');
      el.value = str;
      el.setAttribute('readonly', '');
      el.style.position = 'absolute';
      el.style.left = '-9999px';
      document.body.appendChild(el);
      const selected =
        document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
        if (selected) {
          document.getSelection().removeAllRanges();
          document.getSelection().addRange(selected);
        }
        return true;
      } catch(e) {
        return false;
      }
    }
    `)

  type state =
    | Init
    | Copied
    | Failed

  @react.component
  let make = (~code) => {
    let (state, setState) = React.useState(_ => Init)

    let buttonRef = React.useRef(Js.Nullable.null)

    let onClick = evt => {
      ReactEvent.Mouse.preventDefault(evt)
      if copyToClipboard(code) {
        setState(_ => Copied)
      } else {
        setState(_ => Failed)
      }
    }

    React.useEffect1(() => {
      switch state {
      | Copied =>
        let timeoutId = Js.Global.setTimeout(() => {
          setState(_ => Init)
        }, 3000)

        Some(
          () => {
            Js.Global.clearTimeout(timeoutId)
          },
        )
      | _ => None
      }
    }, [state])

    <button
      style={ReactDOM.Style.make(
        ~position="absolute",
        ~top="0",
        ~right="0",
        ~border="none",
        ~borderBottom="1px solid rgba(38, 85, 115, 0.15)",
        ~borderLeft="1px solid rgba(38, 85, 115, 0.15)",
        ~backgroundColor="rgb(255, 255, 255)",
        ~borderRadius="0px 0px 0px 5px",
        ~padding="5px 13px",
        ~cursor="pointer",
        (),
      )}
      ref={ReactDOM.Ref.domRef(buttonRef)}
      disabled={state === Copied}
      className="relative"
      onClick>
      {state !== Copied ? "Copy"->React.string : "Copied"->React.string}
    </button>
  }
}

let getMdxChildren: 'a => 'a = %raw("element => {
      if(typeof element === 'string') {
        return element;
      }
      if(element == null || element.props == null || element.props.children == null) {
        return;
      }
      return element.props.children;
    }")

type highlightLine = {start: int, end?: int}

@react.component
let make = (~children, ~highlightLines: array<highlightLine>=[]) => {
  let child = Js.String.make(children->getMdxChildren->getMdxChildren)

  React.useEffect1(() => {
    let options: array<
      HighlightLine.highlightLinesOption,
    > = highlightLines->Belt.Array.map(line => {
      let start = line.start
      let end = switch line.end {
      | Some(end) => end
      | None => start
      }

      let option: HighlightLine.highlightLinesOption = {
        start,
        end,
        color: "rgb(213 210 208)",
      }

      option
    })

    let _ =
      document
      ->querySelector("code")
      ->Belt.Option.map(code => {
        HighlightLine.highlightLinesCode(code, options)
      })

    None
  }, [])

  <div
    style={ReactDOM.Style.make(
      ~position="relative",
      ~border="1px solid hsla(203, 50%, 30%, 0.15)",
      ~boxShadow="rgba(0, 0, 0, 0.10) 0 1px 3px 0",
      ~backgroundColor="rgb(245, 242, 240)",
      (),
    )}>
    <pre style={ReactDOM.Style.make(~margin="0", ~padding="10px", ~overflow="auto", ())}>
      <code
        className="hljs lang-res"
        dangerouslySetInnerHTML={
          "__html": highlight(~code=child, ~options={language: "res"})
          ->valueGet
          ->Js.String.replaceByRe(%re("/\*\*(.*)\*\*/g"), "<mark>$1$1</mark>", _),
        }
      />
    </pre>
    <CopyButton code={child->Js.String.make->Js.String.trim} />
  </div>
}
