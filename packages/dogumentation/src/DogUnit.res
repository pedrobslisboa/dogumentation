module Styles = {
  let controls = ReactDOM.Style.make(
    ~border=`1px solid ${Theme.Color.midGray}`,
    ~backgroundColor=Theme.Color.lightGray,
    ~borderRadius="8px",
    ~marginTop="10px",
    (),
  )
}

let getRightSidebarElement = (): option<Dom.element> =>
  Bindings.Window.Iframe.contentWindow()["document"]["body"]["querySelector"](.
    "#controls-root",
  )->Js.Nullable.toOption

@react.component
let make = (~demoUnit: Controls.demoUnitProps => React.element, ~controlsOrientation=#vertical) => {
  let (showControls, setShowControls) = React.useState(() => false)
  let (style, _, _) = ResponsiveContext.useResponsiveContext()

  let {
    state,
    onStringChange,
    onBoolChange,
    onFloatChange,
    onIntChange,
  } = Controls.useControls(props => {
    let _ = demoUnit(props)
  })

  let hasControls = switch (
    state.strings->Belt.Map.String.size,
    state.ints->Belt.Map.String.size,
    state.floats->Belt.Map.String.size,
    state.bools->Belt.Map.String.size,
  ) {
  | (0, 0, 0, 0) => false
  | _ => true
  }

  let props: Controls.demoUnitProps = {
    string: (name, ~options as _=?, _config) => {
      let (_, value, _) = state.strings->Belt.Map.String.getExn(name)
      value
    },
    int: (name, _config) => {
      let (_, value) = state.ints->Belt.Map.String.getExn(name)
      value
    },
    float: (name, _config) => {
      let (_, value) = state.floats->Belt.Map.String.getExn(name)
      value
    },
    bool: (name, _config) => {
      let (_, value) = state.bools->Belt.Map.String.getExn(name)
      value
    },
  }

  <div
    style={ReactDOM.Style.make(
      ~display="flex",
      ~flexDirection=switch controlsOrientation {
      | #vertical => "row"
      | #horizontal => "column"
      },
      ~width="100%",
      ~flex="1",
      ~justifyContent="space-between",
      (),
    )}>
    <div
      style={ReactDOM.Style.make(
        ~position="relative",
        ~backgroundColor=Theme.Color.midGray,
        ~flex="1",
        (),
      )}>
      <div
        style={ReactDOM.Style.make(~width=style.width, ~height=style.height, ~margin="auto", ())}>
        <DemoUnit demo={demoUnit(props)} />
      </div>
      {switch hasControls {
      | false => React.null
      | true =>
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
          onClick={_ => setShowControls(prev => !prev)}
          className="relative">
          {switch showControls {
          | false => "Show Controls"->React.string
          | true => "Hide Controls"->React.string
          }}
        </button>
      }}
    </div>
    {switch (hasControls, showControls) {
    | (_, false) => React.null
    | (false, _) => React.null
    | (_, true) =>
      <DemoUnitSidebar
        strings=state.strings
        ints=state.ints
        floats=state.floats
        bools=state.bools
        onStringChange={onStringChange}
        onIntChange={onIntChange}
        onFloatChange={onFloatChange}
        onBoolChange={onBoolChange}
      />
    }}
  </div>
}
