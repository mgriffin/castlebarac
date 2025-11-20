import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-fields"
export default class extends Controller {
  static targets = ["fields", "template"];

  append() {
    this.fieldsTarget.insertAdjacentHTML("beforeend", this.#templateContent);
  }

  // private

  get #templateContent() {
    return this.templateTarget.innerHTML.replace(/__INDEX__/g, Date.now());
  }
}
