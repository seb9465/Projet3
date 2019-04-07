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
using System.Windows.Input;
using System.Windows.Media;
using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Modeles;
using PolyPaint.Strokes;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;

namespace PolyPaint.VueModeles
{

    /// <summary>
    /// Sert d'intermédiaire entre la vue et le modèle.
    /// Expose des commandes et propriétés connectées au modèle aux des éléments de la vue peuvent se lier.
    /// Reçoit des avis de changement du modèle et envoie des avis de changements à la vue.
    /// </summary>
    public class VueModele : INotifyPropertyChanged, IChatDataContext
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public event EventHandler OnRotation;
        private Editeur editeur = new Editeur();
        private string _currentRoom;
        private string _selectedBorder;
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private ConcurrentDictionary<string, List<DrawViewModel>> _onlineSelection { get; set; }
        public InkCanvas SurfaceDessin { get; private set; }
        public ChatClient ChatClient { get; set; }
        public CollaborationClient CollaborationClient { get; set; }

        public HubConnection Connection { get; private set; }


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

        public string CurrentRoom
        {
            get { return _currentRoom; }
            set { _currentRoom = value; ProprieteModifiee("CurrentRoom"); ProprieteModifiee("MessagesListBox"); }
        }

        private bool _canvasProtection;
        public bool CanvasProtection
        {
            get { return _canvasProtection; }
            set { _canvasProtection = value; ProprieteModifiee(); }
        }
        private bool _redoEnabled;
        public bool RedoEnabled
        {
            get { return _redoEnabled; }
            set { _redoEnabled = value; ProprieteModifiee(); }
        }
        private bool _undoEnabled;
        public bool UndoEnabled
        {
            get { return _undoEnabled; }
            set { _undoEnabled = value; ProprieteModifiee(); }
        }

        private bool _isCreatedByUser;
        public bool IsCreatedByUser
        {
            get { return _isCreatedByUser; }
            set { _isCreatedByUser = value; ProprieteModifiee(); }
        }
        private bool _isConnected = true;
        public bool IsConnected
        {
            get { return _isConnected; }
            set { _isConnected = value; ProprieteModifiee(); }
        }

        public SaveableCanvas Canvas { get; set; }

        public string OutilSelectionne
        {
            get { return editeur.OutilSelectionne; }
            set { ProprieteModifiee(); }
        }

        public string DefaultColor
        {
            get { return "#00000000"; }
            set { editeur.CouleurSelectionneeBordure = value; ProprieteModifiee("CouleurSelectionneeBordureConverted"); }
        }

        public string CouleurSelectionneeBordure
        {
            get { return editeur.CouleurSelectionneeBordure; }
            set { editeur.CouleurSelectionneeBordure = value; ProprieteModifiee("CouleurSelectionneeBordureConverted"); }
        }

        public string CouleurSelectionneeBordureConverted
        {
            get { return editeur.CouleurSelectionneeBordureConverted; }
        }

        public string CouleurSelectionneeRemplissage
        {
            get { return editeur.CouleurSelectionneeRemplissage; }
            set { editeur.CouleurSelectionneeRemplissage = value; ProprieteModifiee("CouleurSelectionneeRemplissageConverted"); }
        }

        public string CouleurSelectionneeRemplissageConverted
        {
            get { return editeur.CouleurSelectionneeRemplissageConverted; }
            set { editeur.CouleurSelectionneeRemplissage = value; ProprieteModifiee("CouleurSelectionneeRemplissageConverted"); }
        }

        public string PointeSelectionnee
        {
            get { return editeur.PointeSelectionnee; }
            set { ProprieteModifiee(); }
        }

        public int TailleTrait
        {
            get { return editeur.TailleTrait; }
            set
            {
                editeur.TailleTrait = value;
                editeur.SelectedStrokes.ToList().ForEach(x => (x as AbstractStroke).SetBorderThickness(editeur.TailleTrait));
            }
        }

        public string SelectedBorder
        {
            get { return _selectedBorder; }
            set { _selectedBorder = value; ProprieteModifiee(); }
        }

        public DashStyle SelectedBorderDashStyle { get { return _selectedBorder == "" ? DashStyles.Solid : Tools.DashAssociations[_selectedBorder]; } }

        public Boolean IsStrokeSelected
        {
            get { return editeur.SelectedStrokes.Any(x => x is AbstractStroke) && editeur.SelectedStrokes.Count > 0; }
            set { ProprieteModifiee(); }
        }

        public StrokeCollection Traits
        {
            get { return editeur.traits; }
            set { editeur.traits = value; ProprieteModifiee(); }
        }

        // Commandes sur lesquels la vue pourra se connecter.
        public RelayCommand<string> ChoisirPointe { get; set; }
        public RelayCommand<string> ChoisirOutil { get; set; }
        public RelayCommand<string> ChoisirRoom { get; set; }
        public RelayCommand<string> ChooseBorder { get; set; }
        public RelayCommand<string> Rotate { get; set; }
        public RelayCommand<Room> RoomConnect { get; set; }
        public RelayCommand<object> Reinitialiser { get; set; }

        public StrokeCollection SelectItem(Point mouseLeftDownPoint)
        {
            editeur.OutilSelectionne = "select";
            return editeur.SelectItem(SurfaceDessin, mouseLeftDownPoint, this);
        }
        public StrokeCollection SelectItemLasso(Rect bounds)
        {
            editeur.OutilSelectionne = "select";
            return editeur.SelectItemLasso(SurfaceDessin, bounds, this);
        }
        public StrokeCollection SelectItems(StrokeCollection strokes)
        {
            editeur.OutilSelectionne = "select";
            return editeur.SelectItems(SurfaceDessin, strokes, this);
        }
        public void SelectNothing()
        {
            editeur.SelectItemLasso(SurfaceDessin, Rect.Empty, this);
        }

        /// <summary>
        /// Constructeur de VueModele
        /// On récupère certaines données initiales du modèle et on construit les commandes
        /// sur lesquelles la vue se connectera.
        /// </summary>
        public VueModele(ChatClient chatClient, SaveableCanvas canvas, InkCanvas surfaceDessin)
        {
            SurfaceDessin = surfaceDessin;
            ChatClient = chatClient;
            CollaborationClient = new CollaborationClient(canvas.CanvasId);
            _canvasProtection = canvas.CanvasProtection.Length > 0;
            Canvas = canvas;
            IsCreatedByUser = Canvas.CanvasAutor == Application.Current.Properties["username"].ToString();

            // On écoute pour des changements sur le modèle. Lorsqu'il y en a, EditeurProprieteModifiee est appelée.
            editeur.PropertyChanged += new PropertyChangedEventHandler(EditeurProprieteModifiee);

            Traits = editeur.traits;
            
            // Pour les commandes suivantes, il est toujours possible des les activer.
            // Donc, aucune vérification de type Peut"Action" à faire.
            ChoisirPointe = new RelayCommand<string>(editeur.ChoisirPointe);
            ChoisirOutil = new RelayCommand<string>(editeur.ChoisirOutil);
            ChoisirRoom = new RelayCommand<string>(choisirRoom);
            ChooseBorder = new RelayCommand<string>(chooseBorder);
            Rotate = new RelayCommand<string>(rotate);
            RoomConnect = new RelayCommand<Room>(roomConnect);
            Reinitialiser = new RelayCommand<object>(editeur.Reinitialiser);

            ChatClient.MessageReceived += AddMessage;
            ChatClient.ChannelsReceived += InitializeChatRooms;
            ChatClient.ChannelCreated += AddRoomItem;
            ChatClient.ConnectedToChannel += ConnectedToRoom;
            ChatClient.ConnectedToChannelSender += ConnectedToRoomSender;
            ChatClient.DisconnectedFromChannel += DisconnectedFromRoom;
            ChatClient.DisconnectedFromChannelSender += DisconnectedFromRoomSender;

            _selectedBorder = "";
            _onlineSelection = new ConcurrentDictionary<string, List<DrawViewModel>>();
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

        internal async Task UnsubscribeChatClient()
        {
            ChatClient.MessageReceived -= AddMessage;
            ChatClient.ChannelsReceived -= InitializeChatRooms;
            ChatClient.ChannelCreated -= AddRoomItem;
            ChatClient.ConnectedToChannel -= ConnectedToRoom;
            ChatClient.ConnectedToChannelSender -= ConnectedToRoomSender;
            ChatClient.DisconnectedFromChannel -= DisconnectedFromRoom;
            ChatClient.DisconnectedFromChannelSender -= DisconnectedFromRoomSender;
            await ChatClient.Disconnect();
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
            if (e.PropertyName == "OutilSelectionne")
            {
                OutilSelectionne = editeur.OutilSelectionne;
            }
            else // e.PropertyName == "TailleTrait"
            {
            }
        }

        private void choisirRoom(string room)
        {
            CurrentRoom = room;
        }

        private void chooseBorder(string border)
        {
            SelectedBorder = border;

            foreach (AbstractStroke stroke in editeur.SelectedStrokes.Where(x => x is AbstractStroke))
            {
                stroke.SetBorderStyle(Tools.DashAssociations[border]);
            }
            SendSelectedStrokes();
        }

        private void rotate(string side)
        {
            var increment = side == "right" ? 90 : -90;
            foreach (AbstractStroke stroke in editeur.SelectedStrokes.Where(x => x is AbstractStroke))
            {
                stroke.Rotation = (stroke.Rotation + increment) % 360.0;
                var stylusPoint0 = Tools.RotatePoint(stroke.StylusPoints[0].ToPoint(), stroke.Center, increment);
                var stylusPoint1 = Tools.RotatePoint(stroke.StylusPoints[1].ToPoint(), stroke.Center, increment);
                stroke.StylusPoints[0] = new StylusPoint(stylusPoint0.X, stylusPoint0.Y);
                stroke.StylusPoints[1] = new StylusPoint(stylusPoint1.X, stylusPoint1.Y);
            }
            var affectedStrokes = SurfaceDessin.GetSelectedStrokes();
            affectedStrokes.Add(InkCanvasEventManager.UpdateAnchorPointsPosition(SurfaceDessin));
            CollaborationClient.CollaborativeDrawAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(affectedStrokes));
            CollaborationClient.CollaborativeSelectAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(editeur.SelectedStrokes));
            OnRotation?.Invoke(this, new EventArgs());
        }

        public void ChangeSelection(InkCanvas surfaceDessin)
        {
            var strokes = surfaceDessin.GetSelectedStrokes();
            editeur.SelectedStrokes = strokes;
            ProprieteModifiee("IsStrokeSelected");

            HandleBorderColorChange(strokes);
            HandleFillColorChange(strokes);
            HandleBorderStyleChange(strokes);
            HandleThiccnessChange(strokes);
        }

        private void HandleThiccnessChange(StrokeCollection strokes)
        {
            if (strokes.Count() != 0)
                TailleTrait = (int)((AbstractStroke)strokes.First()).Border.Thickness;
            ProprieteModifiee("TailleTrait");
        }

        public void ChangeOnlineSelection(ItemsMessage message)
        {
            _onlineSelection.AddOrUpdate(message.Username, message.Items, (k, v) => { return message.Items; });
        }

        public ConcurrentDictionary<string, List<DrawViewModel>> GetOnlineSelection()
        {
            return _onlineSelection;
        }

        private void HandleBorderColorChange(StrokeCollection strokes)
        {
            if (strokes.Where(x => x is AbstractStroke).Select(x => (x as AbstractStroke).BorderColor).Distinct().Count() > 1 ||
                strokes.Count() == 0)
            {
                CouleurSelectionneeBordure = "";
            }
            else
            {
                CouleurSelectionneeBordure = (strokes.First(x => x is AbstractStroke) as AbstractStroke).BorderColor.ToString();
            }
        }

        private void HandleFillColorChange(StrokeCollection strokes)
        {
            if (strokes.Where(x => x is AbstractStroke).Select(x => (x as AbstractStroke).FillColor).Distinct().Count() > 1 ||
                strokes.Count() == 0)
            {
                CouleurSelectionneeRemplissage = "";
            }
            else
            {
                CouleurSelectionneeRemplissage = (strokes.First(x => x is AbstractStroke) as AbstractStroke).FillColor.ToString();
            }
        }

        private void HandleBorderStyleChange(StrokeCollection strokes)
        {
            if (!strokes.All(x => x is AbstractStroke) ||
                strokes.Select(x => (x as AbstractStroke).BorderStyle).Distinct().Count() > 1 ||
                strokes.Count() == 0)
            {
                SelectedBorder = "";
            }
            else
            {
                SelectedBorder = Tools.DashAssociations.First(x => x.Value == (strokes.First() as AbstractStroke).BorderStyle).Key;
            }
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

        internal void SendSelectedStrokes()
        {
            CollaborationClient.CollaborativeDrawAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(editeur.SelectedStrokes));
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
            //mediaPlayer.Open(new Uri("SoundEffects//receive.mp3", UriKind.Relative));
            //mediaPlayer.Volume = 100;
            //mediaPlayer.Play();
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

        public StrokeCollection GetSelectedStrokes()
        {
            return editeur.SelectedStrokes;
        }
    }
}
