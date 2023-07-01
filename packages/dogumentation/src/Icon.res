let desktop =
  <svg width="32" height="32">
    <g transform="translate(5 8)" fill="none" fillRule="evenodd">
      <rect stroke="currentColor" x="2" width="18" height="13" rx="1" />
      <rect fill="currentColor" y="13" width="22" height="2" rx="1" />
    </g>
  </svg>

let mobile =
  <svg width="32" height="32">
    <g transform="translate(11 7)" fill="none" fillRule="evenodd">
      <rect stroke="currentColor" width="10" height="18" rx="2" />
      <path d="M2 0h6v1a1 1 0 01-1 1H3a1 1 0 01-1-1V0z" fill="currentColor" />
    </g>
  </svg>

let sidebar =
  <svg width="32" height="32">
    <g
      stroke="currentColor"
      strokeWidth="1.5"
      fill="none"
      fillRule="evenodd"
      strokeLinecap="round"
      strokeLinejoin="round">
      <path d="M25.438 17H12.526M19 10.287L12.287 17 19 23.713M8.699 7.513v17.2" />
    </g>
  </svg>

let close =
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="18"
    height="18"
    viewBox="0 0 18 18"
    style={ReactDOM.Style.make(~display="block", ())}>
    <path
      fill="gray"
      d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"
    />
  </svg>

let categoryCollapsed =
  <svg
    width="20"
    height="17"
    viewBox="0 0 20 17"
    fill=Theme.Color.darkGray
    xmlns="http://www.w3.org/2000/svg">
    <rect x="2" y="1" width="16" height="2" />
    <rect x="2" y="7" width="16" height="2" />
    <rect x="2" y="13" width="16" height="2" />
  </svg>

let categoryExpanded =
  <svg
    width="26"
    height="17"
    viewBox="0 0 26 17"
    fill=Theme.Color.darkGray
    xmlns="http://www.w3.org/2000/svg">
    <rect x="6" y="1" width="16" height="2" />
    <rect x="2" y="1" width="2" height="2" />
    <rect x="10" y="7" width="12" height="2" />
    <rect x="6" y="7" width="2" height="2" />
    <rect x="10" y="13" width="12" height="2" />
    <rect x="6" y="13" width="2" height="2" />
  </svg>
