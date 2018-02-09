let Room = {

  init(socket, element, presence){
    if(!element){ return; }
    let roomId = element.getAttribute("data-id")
    socket.connect()
    this.onReady(roomId, socket)
    this.presence = presence
  },
  onReady(roomId, socket){
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let submitBtn = document.getElementById("msg-submit")
    let userList = document.getElementById("user-list")
    let roomChannel = socket.channel("rooms:" + roomId, {})
    // Presence
    let presences = {}

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

    roomChannel.on("new_message", resp => {
      this.renderMessage(msgContainer, resp)
    })

    // presence_state is called when a new user(current user) joins(refresh the page also joins again) the channel.
    // presence_state is called for the current user only to get the existing presences.
    roomChannel.on("presence_state", state => {
      presences = this.presence.syncState(presences, state)
      this.renderPresences(userList, presences)
    })

    // presence_state is broadcasted when a specific user(including current user) joined or leave the channel.
    roomChannel.on("presence_diff", diff => {
      presences = this.presence.syncDiff(presences, diff)
      this.renderPresences(userList, presences)
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
  },
  renderPresences(userList, presences){
    userList.innerHTML = this.presence.list(presences, this.listBy)
    .map(presence => `
      <li>
        <b>${presence.displayName}</b>
        <br><small>online since ${presence.onlineAt}</small>
      </li>
    `).join(" ")
  },
  listBy(user_id, {metas: metas}){
    let date = new Date(metas[0].online_at)
    return {
      displayName: metas[0].display_name,
      onlineAt: date.toLocaleTimeString()
    }
  }
}
export default Room