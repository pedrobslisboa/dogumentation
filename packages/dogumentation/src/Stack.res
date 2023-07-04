module Styles = {
  let stack = ReactDOM.Style.make(
    ~display="flex",
    ~flexDirection="column",
    ~gridGap=Theme.Gap.xs,
    (),
  )
}

@react.component
let make = (~children, ~style=ReactDOM.Style.make()) => {
  <div name="Stack" style={ReactDOM.Style.combine(Styles.stack, style)}> children </div>
}
