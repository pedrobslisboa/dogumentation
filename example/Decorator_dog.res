open Dogumentation.Dog

addToCategory(
  "Decorator sample",
  ~decorators=[
    (dog, {controls}) => {
      let borderColor = controls.string(
        "Color",
        ~options=[("Red", "#E02020"), ("Green", "#6DD400"), ("Blue", "#0091FF")],
        "#0091FF",
      )
      <div style={ReactDOM.Style.make(~border=`1px solid ${borderColor}`, ())}> {dog} </div>
    },
  ],
  ({addDog}) => {
    addDog("Normal", _ => {
      <div>
        {"This is a dog using a decorator, the border was added by the decorator and you can change it color on the rigth sidebar control"->React.string}
      </div>
    })
  },
  (),
)
