type padding = Around | LeftRight | TopLeftRight

type border = None | Bottom

module Styles = {
  let around = gapValue => ReactDOM.Style.make(~padding=gapValue, ~boxSizing="border-box", ())
  let leftRight = gapValue =>
    ReactDOM.Style.make(~padding=`0 ${gapValue}`, ~boxSizing="border-box", ())
  let topLeftRight = gapValue =>
    ReactDOM.Style.make(~padding=`${gapValue} ${gapValue} 0`, ~boxSizing="border-box", ())

  let getPadding = (padding: padding, gap: Theme.Gap.t) => {
    let gapValue = Theme.Gap.getGap(gap)
    switch padding {
    | Around => around(gapValue)
    | LeftRight => leftRight(gapValue)
    | TopLeftRight => topLeftRight(gapValue)
    }
  }

  let getBorder = (border: border) => {
    switch border {
    | None => ReactDOM.Style.make()
    | Bottom => ReactDOM.Style.make(~borderBottom=Theme.Border.default, ())
    }
  }

  let make = (~padding, ~gap, ~border) => {
    let paddingStyles = getPadding(padding, gap)
    let borderStyles = getBorder(border)
    ReactDOM.Style.combine(paddingStyles, borderStyles)
  }
}

@react.component
let make = (
  ~gap: Theme.Gap.t=Xs,
  ~padding: padding=Around,
  ~border: border=None,
  ~id=?,
  ~children,
  ~style=ReactDOM.Style.make(),
) => {
  <div
    name="PaddedBox"
    ?id
    style={ReactDOM.Style.combine(Styles.make(~padding, ~border, ~gap), style)}>
    children
  </div>
}
