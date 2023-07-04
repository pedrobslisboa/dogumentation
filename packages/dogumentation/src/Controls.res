type numberConfig<'a> = {
  min: 'a,
  max: 'a,
  initial: 'a,
  step: 'a,
}

type stringConfig = string

type boolConfig = bool

type demoUnitProps = {
  string: (string, ~options: array<(string, string)>=?, stringConfig) => string,
  int: (string, numberConfig<int>) => int,
  float: (string, numberConfig<float>) => float,
  bool: (string, boolConfig) => bool,
}

type state = {
  strings: Belt.Map.String.t<(stringConfig, string, option<array<(string, string)>>)>,
  ints: Belt.Map.String.t<(numberConfig<int>, int)>,
  floats: Belt.Map.String.t<(numberConfig<float>, float)>,
  bools: Belt.Map.String.t<(boolConfig, bool)>,
}

type action =
  | SetString(string, string)
  | SetInt(string, int)
  | SetFloat(string, float)
  | SetBool(string, bool)

type controls = {
  state: state,
  onStringChange: (string, string) => unit,
  onIntChange: (string, int) => unit,
  onFloatChange: (string, float) => unit,
  onBoolChange: (string, bool) => unit,
}

let useControls = onInit => {
  let (state, dispatch) = React.useReducer(
    (state, action) =>
      switch action {
      | SetString(name, newValue) => {
          ...state,
          strings: state.strings->Belt.Map.String.update(name, value =>
            value->Belt.Option.map(((config, _value, options)) => (config, newValue, options))
          ),
        }
      | SetInt(name, newValue) => {
          ...state,
          ints: state.ints->Belt.Map.String.update(name, value =>
            value->Belt.Option.map(((config, _value)) => (config, newValue))
          ),
        }
      | SetFloat(name, newValue) => {
          ...state,
          floats: state.floats->Belt.Map.String.update(name, value =>
            value->Belt.Option.map(((config, _value)) => (config, newValue))
          ),
        }
      | SetBool(name, newValue) => {
          ...state,
          bools: state.bools->Belt.Map.String.update(name, value =>
            value->Belt.Option.map(((config, _value)) => (config, newValue))
          ),
        }
      },
    {
      let strings = ref(Belt.Map.String.empty)
      let ints = ref(Belt.Map.String.empty)
      let floats = ref(Belt.Map.String.empty)
      let bools = ref(Belt.Map.String.empty)
      let props: demoUnitProps = {
        string: (name, ~options=?, config) => {
          strings := strings.contents->Belt.Map.String.set(name, (config, config, options))
          config
        },
        int: (name, config) => {
          ints := ints.contents->Belt.Map.String.set(name, (config, config.initial))
          config.initial
        },
        float: (name, config) => {
          floats := floats.contents->Belt.Map.String.set(name, (config, config.initial))
          config.initial
        },
        bool: (name, config) => {
          bools := bools.contents->Belt.Map.String.set(name, (config, config))
          config
        },
      }
      onInit(props)
      {
        strings: strings.contents,
        ints: ints.contents,
        floats: floats.contents,
        bools: bools.contents,
      }
    },
  )

  let onStringChange = React.useCallback1(
    (name, value) => dispatch(SetString(name, value)),
    [dispatch],
  )

  let onIntChange = React.useCallback1((name, value) => dispatch(SetInt(name, value)), [dispatch])

  let onFloatChange = React.useCallback1(
    (name, value) => dispatch(SetFloat(name, value)),
    [dispatch],
  )

  let onBoolChange = React.useCallback1((name, value) => dispatch(SetBool(name, value)), [dispatch])

  {
    state,
    onStringChange,
    onIntChange,
    onFloatChange,
    onBoolChange,
  }
}
