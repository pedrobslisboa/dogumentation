module Styles = {
  let container = ReactDOM.Style.make(~background=Theme.Color.midGray, ~height="100%", ())
  let contents =
    ReactDOM.Style.make(
      ~flexGrow="1",
      ~overflowY="auto",
      ~padding="20px",
      ~boxSizing="border-box",
      ~backgroundColor=Theme.Color.white,
      ~margin="auto",
      ~height="100%",
      (),
    )->ReactDOM.Style.unsafeAddProp("WebkitOverflowScrolling", "touch")
}

@react.component
let make = (~demo) =>
  <div name="DemoUnit" style=Styles.container>
    <div style=Styles.contents> {demo} </div>
  </div>
