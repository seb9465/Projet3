using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace PolyPaint
{
    public class Room : INotifyPropertyChanged
    {
        private string _title;
        private bool _connected;
        public string Title
        {
            get { return _title; }
            set { _title = value; ProprieteModifiee(); }
        }
        public bool Connected
        {
            get { return _connected; }
            set { _connected = value; ProprieteModifiee(); }
        }

        public event PropertyChangedEventHandler PropertyChanged;

        public Room(string title, bool connected)
        {
            _title = title;
            _connected = connected;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
