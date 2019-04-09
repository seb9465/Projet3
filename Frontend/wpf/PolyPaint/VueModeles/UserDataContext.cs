using PolyPaint.Common.Messages;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace PolyPaint.VueModeles
{
    public class UserDataContext : INotifyPropertyChanged, IChatDataContext
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public ChatClient ChatClient { get; set; }
        private ObservableCollection<SaveableCanvas> _canvas { get; set; }
        private string _currentRoom;
        public ObservableCollection<string> MessagesListBox
        {
            get
            {
                if (ChatClient.MessagesByChannel.Count == 0 || _currentRoom == null)
                {
                    return new ObservableCollection<string>();
                }
                else
                {
                    return ChatClient.MessagesByChannel.GetOrAdd(_currentRoom, new ObservableCollection<string>());
                }
            }
            set { }
        }

        public ObservableCollection<Room> Rooms
        {
            get { return ChatClient.Rooms; }
            set { ChatClient.Rooms = value; ProprieteModifiee(); }
        }
        public ObservableCollection<SaveableCanvas> Canvas
        {
            get { return _canvas; }
            set { _canvas = value; ProprieteModifiee(); }
        }

        public string CurrentRoom
        {
            get { return _currentRoom; }
            set { _currentRoom = value; ProprieteModifiee("CurrentRoom"); ProprieteModifiee("MessagesListBox"); }
        }

        public RelayCommand<string> ChoisirRoom { get; set; }
        public RelayCommand<Room> RoomConnect { get; set; }

        public UserDataContext(ChatClient chatClient)
        {
            ChoisirRoom = new RelayCommand<string>(choisirRoom);
            RoomConnect = new RelayCommand<Room>(roomConnect);

            ChatClient = chatClient;

            ChatClient.MessageReceived += AddMessage;
            ChatClient.ChannelsReceived += InitializeChatRooms;
            ChatClient.ChannelCreated += AddRoomItem;
            ChatClient.ConnectedToChannel += ConnectedToRoom;
            ChatClient.ConnectedToChannelSender += ConnectedToRoomSender;
            ChatClient.DisconnectedFromChannel += DisconnectedFromRoom;
            ChatClient.DisconnectedFromChannelSender += DisconnectedFromRoomSender;
        }

        private void choisirRoom(string room)
        {
            CurrentRoom = room;
        }

        internal void UnsubscribeChatClient()
        {
            ChatClient.MessageReceived -= AddMessage;
            ChatClient.ChannelsReceived -= InitializeChatRooms;
            ChatClient.ChannelCreated -= AddRoomItem;
            ChatClient.ConnectedToChannel -= ConnectedToRoom;
            ChatClient.ConnectedToChannelSender -= ConnectedToRoomSender;
            ChatClient.DisconnectedFromChannel -= DisconnectedFromRoom;
            ChatClient.DisconnectedFromChannelSender -= DisconnectedFromRoomSender;
        }

        private void roomConnect(Room room)
        {
            if (room.Connected)
            {
                ChatClient.DisconnectFromChannel(room.Title);
            }
            else
            {
                ChatClient.ConnectToChannel(room.Title);
            }
        }

        private void AddMessage(object sender, MessageArgs args)
        {
            AddMessageToRoom(args.ChannelId, $"{args.Timestamp} - {args.Username}: {args.Message}");
        }

        private void InitializeChatRooms(object sender, EventArgs args)
        {
            var channels = ChatClient.GetChannels();
            foreach (Channel channel in channels)
            {
                AddRoom(channel.Name);
            }
        }

        public void AddRoom(string roomName)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                if (!ChatClient.MessagesByChannel.Keys.Contains(roomName))
                {
                    ChatClient.MessagesByChannel.GetOrAdd(roomName, new ObservableCollection<string>());
                    ProprieteModifiee("MessagesListBox");
                }
                if (ChatClient.Rooms.FirstOrDefault(x => x.Title == roomName) == null)
                {
                    ChatClient.Rooms.Add(new Room(roomName, false));
                    ProprieteModifiee("Rooms");
                }
            });
        }

        private void AddRoomItem(object sender, ChannelArgs args)
        {
            AddRoom(args.Channel.Name);
        }

        public void AddMessageToRoom(string room, string message)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                ChatClient.MessagesByChannel.AddOrUpdate(room, new ObservableCollection<string>() { message }, (k, v) =>
                {
                    v.Add(message);
                    return v;
                });
            });
            ProprieteModifiee("MessagesListBox");
        }

        public void ConnectedToRoom(object sender, MessageArgs e)
        {
            AddMessageToRoom(e.Message, $"{e.Username} has connected");
        }

        public void ConnectedToRoomSender(object sender, MessageArgs e)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var room = ChatClient.Rooms.FirstOrDefault(x => x.Title == e.Message);
                if (room != null)
                {
                    room.Connected = true;
                }
                else
                {
                    ChatClient.Rooms.Add(new Room(e.Message, true));
                }
            });
        }

        public void DisconnectedFromRoom(object sender, MessageArgs e)
        {
            AddMessageToRoom(e.Message, $"{e.Username} has disconnected");
        }

        public void DisconnectedFromRoomSender(object sender, MessageArgs e)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var room = ChatClient.Rooms.FirstOrDefault(x => x.Title == e.Message);
                if (room != null)
                {
                    room.Connected = false;
                }
                else
                {
                    ChatClient.Rooms.Add(new Room(e.Message, false));
                }
            });
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
