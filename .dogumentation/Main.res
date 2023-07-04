open Dogumentation.Config

@module("./logo.png")
external logo: string = "default"

module Intro = {
  @react.component
  let make = () => {
    <div>
      <h1> {"Sample Intro Documentation"->React.string} </h1>
      <p> {"Using Dogumentation you can create an easy rescript documentation."->React.string} </p>
      <h2> {"Usage:"->React.string} </h2>
      <p> {"Check out the sidebar to learn more"->React.string} </p>
    </div>
  }
}

let sortDogs = ((a, entity), (b, _)) => {
  switch entity {
  | Dogumentation.Entity.Demo(_) =>
    if a == "Basic" {
      -1
    } else if b == "Basic" {
      1
    } else {
      String.compare(a, b)
    }
  | Dogumentation.Entity.Category(_) =>
    if a == "Typography" {
      -1
    } else if b == "Typography" {
      1
    } else {
      String.compare(a, b)
    }
  | _ => 0
  }
}

let config: config = {
  intro: <Intro />,
  sortDogs,
  logo,
  decorators: [
    (dog, _) => {
      <div> {dog} </div>
    },
  ],
}

start(~config, ())
