export interface PeerToMessages{
  [key: number]: Messages
}


export interface Messages{
  offers: Array<string>,
  answers: Array<string>,
  candidates: Array<string>
}
