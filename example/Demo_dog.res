open Dogumentation.Dog

addToCategory("Buttons", ({addDog}) => {
  addDog("Basic", controls => {
    let disabled = controls.bool("Disabled", false)
    <button
      disabled
      style={ReactDOM.Style.make(
        ~backgroundColor=controls.string(
          "Color",
          ~options=[("Red", "#E02020"), ("Green", "#6DD400"), ("Blue", "#0091FF")],
          "#0091FF",
        ),
        ~color="#fff",
        ~border="none",
        ~padding="10px",
        ~borderRadius="10px",
        ~fontFamily="inherit",
        ~fontSize="inherit",
        ~opacity=disabled ? "0.5" : "1",
        ~cursor=disabled ? "default" : "pointer",
        (),
      )}>
      {controls.string("Text", "hello")->React.string}
    </button>
  })

  addDog("Huge", ({string, bool}) => {
    let disabled = bool("Disabled", false)
    <button
      disabled
      style={ReactDOM.Style.make(
        ~backgroundColor=string(
          "Color",
          ~options=[("Red", "#E02020"), ("Green", "#6DD400"), ("Blue", "#0091FF")],
          "#0091FF",
        ),
        ~color="#fff",
        ~border="none",
        ~padding="20px",
        ~borderRadius="10px",
        ~fontFamily="inherit",
        ~fontSize="30px",
        ~opacity=disabled ? "0.5" : "1",
        ~cursor=disabled ? "default" : "pointer",
        (),
      )}>
      {string("Text", "Hello")->React.string}
    </button>
  })
})

addToCategory("Typography", ({addDog: _, addToSubCategory}) => {
  addToSubCategory("Headings", ({addDog}) => {
    addDog(
      "H1",
      ({string, int}) =>
        <h1
          style={ReactDOM.Style.make(
            ~fontSize={
              let size = int("Font size", {min: 0, max: 100, initial: 30, step: 1})
              `${size->Belt.Int.toString}px`
            },
            (),
          )}>
          {string("Text", "hello")->React.string}
        </h1>,
    )
    addDog("H2", ({string}) => <h2> {string("Text", "hello")->React.string} </h2>)
  })
})

addToCategory("Typography", ({addDog: _, addToSubCategory}) => {
  addToSubCategory("Headings", ({addDog}) => {
    addDog(
      "H1",
      ({string, int}) =>
        <h1
          style={ReactDOM.Style.make(
            ~fontSize={
              let size = int("Font size", {min: 0, max: 100, initial: 30, step: 1})
              `${size->Belt.Int.toString}px`
            },
            (),
          )}>
          {string("Text", "hello")->React.string}
        </h1>,
    )
    addDog("H2", ({string}) => <h2> {string("Text", "hello")->React.string} </h2>)
  })
})

addToCategory("Typography", ({addDog: _, addToSubCategory}) => {
  addToSubCategory("Text", ({addDog}) => {
    addDog("Paragraph", ({string}) => <p> {string("Text", "hello")->React.string} </p>)
    addDog("Italic", ({string}) => <i> {string("Text", "hello")->React.string} </i>)
  })
})
