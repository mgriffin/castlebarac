import { Controller } from "@hotwired/stimulus"

// Switches an event's results between everyone and only Castlebar athletes.
// The switch stays hidden until this connects, since it needs JavaScript.
export default class extends Controller {
  static targets = ["switch", "button"]
  static classes = ["filtered"]

  connect() {
    this.switchTarget.hidden = false
  }

  show({ currentTarget, params: { clubOnly } }) {
    this.element.classList.toggle(this.filteredClass, clubOnly)
    this.buttonTargets.forEach((button) => {
      const pressed = button === currentTarget
      button.classList.toggle("active", pressed)
      button.setAttribute("aria-pressed", pressed)
    })
  }
}
