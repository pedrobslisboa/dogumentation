open Dogumentation.Dog

let render = () =>
    addToCategory("Other Sample", ({addDog}) => {
      addDog(
        "Normal",
        ({string, bool}) => {
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
              ~padding="10px",
              ~borderRadius="10px",
              ~fontFamily="inherit",
              ~fontSize="inherit",
              ~opacity=disabled ? "0.5" : "1",
              ~cursor=disabled ? "default" : "pointer",
              (),
            )}>
            {string("Text", "hello")->React.string}
          </button>
        },
      )
    })
