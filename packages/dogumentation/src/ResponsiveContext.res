type t =
  | Mobile
  | Desktop

type responsive = {
  height: string,
  width: string,
}

type contextType = {
  responsiveMode: t,
  changeResponsiveMode: t => unit,
}

module Context = {
  type context = React.Context.t<contextType>

  let context: context = React.createContext({
    responsiveMode: Desktop,
    changeResponsiveMode: _ => (),
  })

  module Provider = {
    let makeProps = (~value, ~children, ()): React.Context.props<_> => {value, children}
    let make = React.Context.provider(context)
  }
}

let useResponsiveContext = () => {
  let {responsiveMode, changeResponsiveMode} = React.useContext(Context.context)

  let styles = switch responsiveMode {
  | Mobile => {
      height: "667px",
      width: "375px",
    }
  | Desktop => {
      height: "100%",
      width: "100%",
    }
  }

  (styles, responsiveMode, changeResponsiveMode)
}

@react.component
let make = (~children, ~responsiveMode) => {
  let (responsiveMode, setResponsiveMode) = React.useState(() => responsiveMode)

  let changeResponsiveMode = newResponsiveMode => {
    setResponsiveMode(_ => newResponsiveMode)
  }

  <Context.Provider value={responsiveMode, changeResponsiveMode}> {children} </Context.Provider>
}
