open Dogumentation.Dog

@module("./Dogx.mdx")
external dogxMdx: unit => React.element = "default"

addToCategory(
  "Dogs",
  ({addDog, addDogx}) => {
    addDogx("Dogxment", dogxMdx)

    addDog("With controls", controls => {
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

    addDog("Without controls", _ => {
      <button
        style={ReactDOM.Style.make(
          ~backgroundColor="#0091FF",
          ~color="#fff",
          ~border="none",
          ~padding="10px",
          ~borderRadius="10px",
          ~fontFamily="inherit",
          ~fontSize="inherit",
          (),
        )}>
        {"hello"->React.string}
      </button>
    })
  },
  (),
)
