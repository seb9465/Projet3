using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Media;
using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;

namespace PolyPaint.VueModeles
{

    /// <summary>
    /// Sert d'intermédiaire entre la vue et le modèle.
    /// Expose des commandes et propriétés connectées au modèle aux des éléments de la vue peuvent se lier.
    /// Reçoit des avis de changement du modèle et envoie des avis de changements à la vue.
    /// </summary>
    class VueModele : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private Editeur editeur = new Editeur();
        private string _currentRoom;
        private ObservableCollection<Room> _rooms;
        private ConcurrentDictionary<string, ObservableCollection<string>> _messagesByChannel { get; set; }
        private MediaPlayer mediaPlayer = new MediaPlayer();

        public ChatClient ChatClient { get; set; }

        // Ensemble d'attributs qui définissent l'apparence d'un trait.
        public DrawingAttributes AttributsDessin { get; set; } = new DrawingAttributes();

        public HubConnection Connection { get; private set; }

        public ObservableCollection<string> MessagesListBox
        {
            get
            {
                if (_messagesByChannel.Count == 0 || _currentRoom == null)
                {
                    return new ObservableCollection<string>();
                }
                else
                {
                    return _messagesByChannel.GetOrAdd(_currentRoom, new ObservableCollection<string>());
                }
            }
            set { }
        }

        public ObservableCollection<Room> Rooms
        {
            get { return _rooms; }
            set { _rooms = value; ProprieteModifiee(); }
        }

        public string CurrentRoom
        {
            get { return _currentRoom; }
            set { _currentRoom = value; ProprieteModifiee("CurrentRoom"); ProprieteModifiee("MessagesListBox"); }
        }

        public string OutilSelectionne
        {
            get { return editeur.OutilSelectionne; }
            set { ProprieteModifiee(); }
        }

        public string CouleurSelectionnee
        {
            get { return editeur.CouleurSelectionnee; }
            set { editeur.CouleurSelectionnee = value; }
        }

        public string PointeSelectionnee
        {
            get { return editeur.PointeSelectionnee; }
            set { ProprieteModifiee(); }
        }

        public int TailleTrait
        {
            get { return editeur.TailleTrait; }
            set { editeur.TailleTrait = value; }
        }

        public StrokeCollection Traits { get; set; }

        // Commandes sur lesquels la vue pourra se connecter.
        public RelayCommand<object> Empiler { get; set; }
        public RelayCommand<object> Depiler { get; set; }
        public RelayCommand<string> ChoisirPointe { get; set; }
        public RelayCommand<string> ChoisirOutil { get; set; }
        public RelayCommand<string> ChoisirRoom { get; set; }
        public RelayCommand<Room> RoomConnect { get; set; }
        public RelayCommand<object> Reinitialiser { get; set; }

        /// <summary>
        /// Constructeur de VueModele
        /// On récupère certaines données initiales du modèle et on construit les commandes
        /// sur lesquelles la vue se connectera.
        /// </summary>
        public VueModele()
        {
            ChatClient = new ChatClient();

            // On écoute pour des changements sur le modèle. Lorsqu'il y en a, EditeurProprieteModifiee est appelée.
            editeur.PropertyChanged += new PropertyChangedEventHandler(EditeurProprieteModifiee);

            // On initialise les attributs de dessin avec les valeurs de départ du modèle.
            AttributsDessin = new DrawingAttributes();
            AttributsDessin.Color = (Color)ColorConverter.ConvertFromString(editeur.CouleurSelectionnee);
            AjusterPointe();

            Traits = editeur.traits;

            // Pour chaque commande, on effectue la liaison avec des méthodes du modèle.            
            Empiler = new RelayCommand<object>(editeur.Empiler, editeur.PeutEmpiler);
            Depiler = new RelayCommand<object>(editeur.Depiler, editeur.PeutDepiler);
            // Pour les commandes suivantes, il est toujours possible des les activer.
            // Donc, aucune vérification de type Peut"Action" à faire.
            ChoisirPointe = new RelayCommand<string>(editeur.ChoisirPointe);
            ChoisirOutil = new RelayCommand<string>(editeur.ChoisirOutil);
            ChoisirRoom = new RelayCommand<string>(choisirRoom);
            RoomConnect = new RelayCommand<Room>(roomConnect);
            Reinitialiser = new RelayCommand<object>(editeur.Reinitialiser);

            ChatClient.MessageReceived += AddMessage;
            ChatClient.ChannelsReceived += InitializeChatRooms;
            ChatClient.ChannelCreated += AddRoomItem;
            ChatClient.ConnectedToChannel += ConnectedToRoom;
            ChatClient.ConnectedToChannelSender += ConnectedToRoomSender;
            ChatClient.DisconnectedFromChannel += DisconnectedFromRoom;
            ChatClient.DisconnectedFromChannelSender += DisconnectedFromRoomSender;

            _messagesByChannel = new ConcurrentDictionary<string, ObservableCollection<string>>();
            _rooms = new ObservableCollection<Room>();
        }

        /// <summary>
        /// Appelee lorsqu'une propriété de VueModele est modifiée.
        /// Un évènement indiquant qu'une propriété a été modifiée est alors émis à partir de VueModèle.
        /// L'évènement qui contient le nom de la propriété modifiée sera attrapé par la vue qui pourra
        /// alors mettre à jour les composants concernés.
        /// </summary>
        /// <param name="propertyName">Nom de la propriété modifiée.</param>
        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        /// <summary>
        /// Traite les évènements de modifications de propriétés qui ont été lancés à partir
        /// du modèle.
        /// </summary>
        /// <param name="sender">L'émetteur de l'évènement (le modèle)</param>
        /// <param name="e">Les paramètres de l'évènement. PropertyName est celui qui nous intéresse. 
        /// Il indique quelle propriété a été modifiée dans le modèle.</param>
        private void EditeurProprieteModifiee(object sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "CouleurSelectionnee")
            {
                AttributsDessin.Color = (Color)ColorConverter.ConvertFromString(editeur.CouleurSelectionnee);
            }
            else if (e.PropertyName == "OutilSelectionne")
            {
                OutilSelectionne = editeur.OutilSelectionne;
            }
            else if (e.PropertyName == "PointeSelectionnee")
            {
                PointeSelectionnee = editeur.PointeSelectionnee;
                AjusterPointe();
            }
            else // e.PropertyName == "TailleTrait"
            {
                AjusterPointe();
            }
        }

        /// <summary>
        /// C'est ici qu'est défini la forme de la pointe, mais aussi sa taille (TailleTrait).
        /// Pourquoi deux caractéristiques se retrouvent définies dans une même méthode? Parce que pour créer une pointe 
        /// horizontale ou verticale, on utilise une pointe carrée et on joue avec les tailles pour avoir l'effet désiré.
        /// </summary>
        private void AjusterPointe()
        {
            AttributsDessin.StylusTip = (editeur.PointeSelectionnee == "ronde") ? StylusTip.Ellipse : StylusTip.Rectangle;
            AttributsDessin.Width = (editeur.PointeSelectionnee == "verticale") ? 1 : editeur.TailleTrait;
            AttributsDessin.Height = (editeur.PointeSelectionnee == "horizontale") ? 1 : editeur.TailleTrait;
        }

        private void choisirRoom(string room)
        {
            CurrentRoom = room;
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
                if (!_messagesByChannel.Keys.Contains(roomName))
                {
                    _messagesByChannel.GetOrAdd(roomName, new ObservableCollection<string>());
                    ProprieteModifiee("MessagesListBox");
                }
                if (_rooms.FirstOrDefault(x => x.Title == roomName) == null)
                {
                    _rooms.Add(new Room(roomName, false));
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
                _messagesByChannel.AddOrUpdate(room, new ObservableCollection<string>() { message }, (k, v) =>
                {
                    v.Add(message);
                    return v;
                });
            });
            ProprieteModifiee("MessagesListBox");
            mediaPlayer.Open(new Uri("SoundEffects//receive.mp3", UriKind.Relative));
            mediaPlayer.Volume = 100;
            mediaPlayer.Play();
        }

        public void ConnectedToRoom(object sender, MessageArgs e)
        {
            AddMessageToRoom(e.Message, $"{e.Username} has connected");
        }

        public void ConnectedToRoomSender(object sender, MessageArgs e)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var room = _rooms.FirstOrDefault(x => x.Title == e.Message);
                if (room != null)
                {
                    room.Connected = true;
                }
                else
                {
                    _rooms.Add(new Room(e.Message, true));
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
                var room = _rooms.FirstOrDefault(x => x.Title == e.Message);
                if (room != null)
                {
                    room.Connected = false;
                }
                else
                {
                    _rooms.Add(new Room(e.Message, false));
                }
            });
        }
    }
}
