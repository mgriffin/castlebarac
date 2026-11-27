import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["event", "confirmation", "checkbox"]

  connect() {
    this.toggle()
  }

  toggle() {
    const entering = this.eventTarget.checked
    this.confirmationTarget.hidden = !entering
    this.checkboxTarget.required = entering
  }
}
