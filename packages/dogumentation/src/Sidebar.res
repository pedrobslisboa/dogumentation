module Styles = {
  let width = "230px"

  let sidebar = (~fullHeight) =>
    ReactDOM.Style.make(
      ~minWidth=width,
      ~width,
      ~height={fullHeight ? "100vh" : "auto"},
      ~overflowY="auto",
      ~backgroundColor=Theme.Color.lightGray,
      (),
    )->ReactDOM.Style.unsafeAddProp("WebkitOverflowScrolling", "touch")
}

@react.component
let make = (~innerContainerId=?, ~fullHeight=false, ~children=React.null) => {
  <div name="Sidebar" id=?innerContainerId style={Styles.sidebar(~fullHeight)}> children </div>
}
