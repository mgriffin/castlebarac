import { Controller } from "@hotwired/stimulus"

// Asks for a club coach's OK only once the event it's for is ticked
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
