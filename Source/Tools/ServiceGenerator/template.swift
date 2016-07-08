public enum YouTube {
           public enum Playlists {
                  case delete(let id: String):
                  case delete(let id: String, let contentOwner: String):
                  case insert(let part: String, let playlist: Playlist):
                  case insert(let id: String, let contentOwner: String, let conentOwnerChannel: String):
                  case list(let part: String):
                  case list(let part: String):
                  case update(let part: String, playlist: Playlist):
                  }
       }


YouTubeProvider.request(.Playlists.list())
