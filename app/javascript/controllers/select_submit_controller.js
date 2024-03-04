import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-submit"
export default class extends Controller {
  submit() {
    this.element.submit()
  }
}
