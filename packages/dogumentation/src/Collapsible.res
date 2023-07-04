module Styles = {
  let clickableArea = ReactDOM.Style.make(
    ~display="flex",
    ~cursor="pointer",
    ~gridGap="2px",
    ~alignItems="center",
    (),
  )
}

let triangleIcon = isOpen =>
  <svg
    width="10"
    height="6"
    style={ReactDOM.Style.make(
      ~transition="200ms ease-out transform",
      ~transform=isOpen ? "" : "rotate(-90deg)",
      (),
    )}>
    <polygon points="0,0  10,0  5,6" fill=Theme.Color.darkGray />
  </svg>

@react.component
let make = (~title: React.element, ~initialValue=false, ~children) => {
  let (isOpen, setIsOpen) = React.useState(() => initialValue)

  <div>
    <div style=Styles.clickableArea onClick={_event => setIsOpen(isOpen => !isOpen)}>
      {triangleIcon(isOpen)}
      title
    </div>
    {isOpen ? children : React.null}
  </div>
}
