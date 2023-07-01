module Styles = {
  let stack = ReactDOM.Style.make(~display="grid", ~gridGap=Theme.Gap.xs, ())
}

@react.component
let make = (~children) => {
  <div name="Stack" style={Styles.stack}> children </div>
}
