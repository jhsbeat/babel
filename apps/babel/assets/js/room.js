let Room = {

  init(socket, element){
    if(!element){ return; }
    let roomId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(roomId, socket)
  },
  onReady(roomId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let submitBtn = document.getElementById("msg-submit")
    let roomChannel = socket.channel("rooms:" + roomId, {})

    submitBtn.addEventListener("click", e => {
      this.sendMessage(msgInput, roomChannel)
    })

    msgInput.addEventListener("keypress", e => {
      let keyCode = e.which || e.keyCode
      if(keyCode == 13){
        e.preventDefault()
        this.sendMessage(msgInput, roomChannel)
      }
    })

    roomChannel.on("new_message", (resp) => {
      this.renderMessage(msgContainer, resp)
    })

    roomChannel.join()
      .receive("ok", resp => { 
        console.log("Joined successfully", resp) 
        this.renderMessages(msgContainer, resp.messages)
      })
      .receive("error", resp => { console.log("Unable to join", resp) })
  },
  sendMessage(msgInput, roomChannel){
    let message = {body: msgInput.value}
    roomChannel.push("new_message", message)
    msgInput.value = ""
  },
  esc(str){
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },
  renderMessages(msgContainer, messages){
    messages.forEach(message => {
      this.renderMessage(msgContainer, message)
    })
  },
  renderMessage(msgContainer, {user, body}){
    let template = document.createElement("div")
    // TODO : Compare user.id with current_user.id to set text-right class.
    if(user.id == -1){
      template.setAttribute("class", "text-right")
    }
    template.innerHTML = `
      <b>${this.esc(user.display_name)}</b>: ${this.esc(body)}
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  }
}
export default Room