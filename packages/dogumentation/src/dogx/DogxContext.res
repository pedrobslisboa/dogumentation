type context = React.Context.t<Js.Dict.t<React.element>>

let context: context = React.createContext(Js.Dict.empty())

module Provider = {
  let makeProps = (~value, ~children, ()): React.Context.props<_> => {value, children}
  let make = React.Context.provider(context)
}

let useDogxContext = () => React.useContext(context)
