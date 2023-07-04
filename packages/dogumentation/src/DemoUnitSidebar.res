open Belt

module Gap = Theme.Gap
module Color = Theme.Color
module Border = Theme.Border
module BorderRadius = Theme.BorderRadius
module FontSize = Theme.FontSize

module Styles = {
  let label = ReactDOM.Style.make(
    ~backgroundColor=Color.white,
    ~borderRadius=BorderRadius.default,
    ~boxShadow="0 5px 10px rgba(0, 0, 0, 0.07)",
    ~justifyContent="center",
    ~display="flex",
    ~flexDirection="column",
    ~cursor="pointer",
    (),
  )

  let labelText = ReactDOM.Style.make(~fontSize=FontSize.md, ~textAlign="center", ())

  let textInput = ReactDOM.Style.make(
    ~fontSize=FontSize.md,
    ~width="100%",
    ~boxSizing="border-box",
    ~backgroundColor=Color.lightGray,
    ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
    ~border="none",
    ~padding=Gap.md,
    ~borderRadius=BorderRadius.default,
    (),
  )

  let select =
    ReactDOM.Style.make(
      ~fontSize=FontSize.md,
      ~width="100%",
      ~boxSizing="border-box",
      ~backgroundColor=Color.lightGray,
      ~boxShadow="inset 0 0 0 1px rgba(0, 0, 0, 0.1)",
      ~border="none",
      ~padding=Gap.md,
      ~borderRadius=BorderRadius.default,
      ~appearance="none",
      ~paddingRight="30px",
      ~backgroundImage=`url("data:image/svg+xml,%3Csvg width='36' height='36' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='%2342484E' stroke-width='2' d='M12.246 14.847l5.826 5.826 5.827-5.826' fill='none' fill-rule='evenodd' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E")`,
      ~backgroundPosition="center right",
      ~backgroundSize="contain",
      ~backgroundRepeat="no-repeat",
      (),
    )->ReactDOM.Style.unsafeAddProp("WebkitAppearance", "none")

  let checkbox = ReactDOM.Style.make(~fontSize=FontSize.md, ~margin="0 auto", ~display="block", ())
}

module PropBox = {
  @react.component
  let make = (~propName: string, ~children, ~style=ReactDOM.Style.make()) => {
    <label style={ReactDOM.Style.combine(Styles.label, style)}>
      <PaddedBox>
        <Stack>
          <div style=Styles.labelText> {propName->React.string} </div>
          children
        </Stack>
      </PaddedBox>
    </label>
  }
}

@react.component
let make = (
  ~strings: Map.String.t<(Controls.stringConfig, string, option<array<(string, string)>>)>,
  ~ints: Map.String.t<(Controls.numberConfig<int>, int)>,
  ~floats: Map.String.t<(Controls.numberConfig<float>, float)>,
  ~bools: Map.String.t<(Controls.boolConfig, bool)>,
  ~onStringChange,
  ~onIntChange,
  ~onFloatChange,
  ~onBoolChange,
  ~orientation=#horizontal,
) =>
  <PaddedBox
    style={ReactDOM.Style.make(
      ~backgroundColor=Theme.Color.lightGray,
      ~borderTop=`1px solid ${Theme.Color.midGray}`,
      ~height="100%",
      (),
    )}
    gap=Md>
    <Stack
      style={switch orientation {
      | #horizontal =>
        ReactDOM.Style.make(
          ~display="grid",
          ~gridTemplateColumns="repeat(auto-fill, minmax(200px, 1fr))",
          (),
        )
      | #vertical => ReactDOM.Style.make()
      }}>
      {strings
      ->Map.String.toArray
      ->Array.map(((propName, (_config, value, options))) =>
        <PropBox style={ReactDOM.Style.make(~flex="1", ())} key=propName propName>
          {switch options {
          | None =>
            <input
              type_="text"
              value
              style=Styles.textInput
              onChange={event => onStringChange(propName, (event->ReactEvent.Form.target)["value"])}
            />
          | Some(options) =>
            <select
              style=Styles.select
              value={value}
              onChange={event => {
                let value = (event->ReactEvent.Form.target)["value"]
                onStringChange(propName, value)
              }}>
              {options
              ->Array.map(((key, optionValue)) => {
                <option key value={optionValue}> {key->React.string} </option>
              })
              ->React.array}
            </select>
          }}
        </PropBox>
      )
      ->React.array}
      {ints
      ->Map.String.toArray
      ->Array.map(((propName, ({min, max}, value))) =>
        <PropBox style={ReactDOM.Style.make(~flex="1", ())} key=propName propName>
          <input
            type_="number"
            min={Belt.Int.toString(min)}
            max={Belt.Int.toString(max)}
            value={Belt.Int.toString(value)}
            style=Styles.textInput
            onChange={event =>
              onIntChange(propName, (event->ReactEvent.Form.target)["value"]->int_of_string)}
          />
        </PropBox>
      )
      ->React.array}
      {floats
      ->Map.String.toArray
      ->Array.map(((propName, ({min, max}, value))) =>
        <PropBox style={ReactDOM.Style.make(~flex="1", ())} key=propName propName>
          <input
            type_="number"
            min={`${min->Belt.Float.toString}`}
            max={`${max->Belt.Float.toString}`}
            value={`${value->Belt.Float.toString}`}
            style=Styles.textInput
            onChange={event =>
              onFloatChange(propName, (event->ReactEvent.Form.target)["value"]->float_of_string)}
          />
        </PropBox>
      )
      ->React.array}
      {bools
      ->Map.String.toArray
      ->Array.map(((propName, (_config, checked))) =>
        <PropBox style={ReactDOM.Style.make(~flex="1", ())} key=propName propName>
          <input
            type_="checkbox"
            checked
            style=Styles.checkbox
            onChange={event => onBoolChange(propName, (event->ReactEvent.Form.target)["checked"])}
          />
        </PropBox>
      )
      ->React.array}
    </Stack>
  </PaddedBox>
