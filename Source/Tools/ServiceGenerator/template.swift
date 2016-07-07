public enum YouTube {
           public enum Playlists {
                  case delete:
                  case insert:
                  case list:
                  case update:
                  }
       }


YouTubeProvider.request(.Playlists.list())
