type rec t =
  | Demo(Controls.demoUnitProps => React.element)
  | Category(Js.Dict.t<t>)
  | Dogx(unit => React.element, Js.Dict.t<t>)
