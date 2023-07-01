module Color = {
  let white = "#fff"
  let lightGray = "#f5f6f6"
  let midGray = "#e0e2e4"
  let darkGray = "#42484d"
  let black40a = "rgba(0, 0, 0, 0.4)"
  let blue = "#0091ff"
  let orange = "#ffae4b"
  let transparent = "transparent"
}

module Gap = {
  let xxs = "2px"
  let xs = "5px"
  let md = "8px"

  type t = Xxs | Xs | Md

  let getGap = (gap: t) =>
    switch gap {
    | Xxs => xxs
    | Xs => xs
    | Md => md
    }
}

module Border = {
  let default = `1px solid ${Color.midGray}`
}

module BorderRadius = {
  let default = "5px"
}

module FontSize = {
  let sm = "12px"
  let md = "14px"
  let lg = "20px"
}
