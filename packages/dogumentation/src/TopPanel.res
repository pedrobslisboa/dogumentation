module Styles = {
  let panel = ReactDOM.Style.make(
    ~display="flex",
    ~justifyContent="flex-end",
    ~borderBottom=Theme.Border.default,
    (),
  )

  let buttonGroup = ReactDOM.Style.make(
    ~overflow="hidden",
    ~display="flex",
    ~flexDirection="row",
    ~alignItems="stretch",
    ~borderRadius=Theme.BorderRadius.default,
    (),
  )

  let button = ReactDOM.Style.make(
    ~height="32px",
    ~width="48px",
    ~cursor="pointer",
    ~fontSize=Theme.FontSize.sm,
    ~backgroundColor=Theme.Color.lightGray,
    ~color=Theme.Color.darkGray,
    ~border="none",
    ~margin="0",
    ~padding="0",
    ~display="flex",
    ~alignItems="center",
    ~justifyContent="center",
    (),
  )

  let squareButton = button->ReactDOM.Style.combine(ReactDOM.Style.make(~width="32px", ()))

  let activeButton =
    button->ReactDOM.Style.combine(
      ReactDOM.Style.make(~backgroundColor=Theme.Color.blue, ~color=Theme.Color.white, ()),
    )

  let middleSection = ReactDOM.Style.make(~display="flex", ~flex="1", ~justifyContent="center", ())

  let rightSection = ReactDOM.Style.make(~display="flex", ())
}

type responsiveMode = Desktop | Mobile

@react.component
let make = (~onChangeResposiveMode, ~responsiveMode) => {
  <div style=Styles.panel>
    <div style=Styles.rightSection />
    <div style=Styles.middleSection>
      <PaddedBox gap=Md>
        <div style=Styles.buttonGroup>
          <button
            title={"Show in desktop mode"}
            style={responsiveMode == Desktop ? Styles.activeButton : Styles.button}
            onClick={event => {
              event->ReactEvent.Mouse.preventDefault
              onChangeResposiveMode(Desktop)
            }}>
            {Icon.desktop}
          </button>
          <button
            title={"Show in mobile mode"}
            style={responsiveMode == Mobile ? Styles.activeButton : Styles.button}
            onClick={event => {
              event->ReactEvent.Mouse.preventDefault
              onChangeResposiveMode(Mobile)
            }}>
            {Icon.mobile}
          </button>
        </div>
      </PaddedBox>
    </div>
  </div>
}
