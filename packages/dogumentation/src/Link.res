@react.component
let make = (~href, ~text: React.element, ~style=?, ~activeStyle=?) => {
  let url = RescriptReactRouter.useUrl()
  let path = String.concat("", url.path)
  let isActive =
    "/" ++
    path ++
    switch url.search {
    | "" => ""
    | _ => "?" ++ url.search
    } == href

  <a
    href
    onClick={event =>
      switch (ReactEvent.Mouse.metaKey(event), ReactEvent.Mouse.ctrlKey(event)) {
      | (false, false) =>
        ReactEvent.Mouse.preventDefault(event)
        RescriptReactRouter.push(href)
      | _ => ()
      }}
    style=?{switch (style, activeStyle, isActive) {
    | (Some(style), _, false) => Some(style)
    | (Some(style), None, true) => Some(style)
    | (Some(style), Some(activeStyle), true) => Some(ReactDOM.Style.combine(style, activeStyle))
    | (_, Some(activeStyle), true) => Some(activeStyle)
    | _ => None
    }}>
    text
  </a>
}
