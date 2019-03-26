using System;
using System.Globalization;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;

namespace PolyPaint.Convertisseurs
{

    class ConvertisseurRoomCouleurFond : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return (bool)value ? Brushes.GreenYellow : (SolidColorBrush)(new BrushConverter().ConvertFrom("#FFDDDDDD"));

        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture) => System.Windows.DependencyProperty.UnsetValue;
    }

    class ConvertisseurRoomContent : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return (bool)value ? "Connected" : "Disconnected";
        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture) => System.Windows.DependencyProperty.UnsetValue;
    }


    /// <summary>
    /// Permet de générer une couleur en fonction de la chaine passée en paramètre.
    /// Par exemple, pour chaque bouton d'un groupe d'options on compare son nom avec l'élément actif (sélectionné) du groupe.
    /// S'il y a correspondance, la bordure du bouton aura une teinte bleue, sinon elle sera transparente.
    /// Cela permet de mettre l'option sélectionnée dans un groupe d'options en évidence.
    /// </summary>
    class ConvertisseurBordure : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return (value.ToString() == parameter.ToString()) ? "#66ff2500" : "#00000000";
        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture) => System.Windows.DependencyProperty.UnsetValue;
    }

    /// Permet de générer une couleur en fonction de la chaine passée en paramètre.
    /// Par exemple, pour chaque bouton d'un groupe d'option on compare son nom avec l'élément actif (sélectionné) du groupe.
    /// S'il y a correspondance, la couleur de fond du bouton aura une teinte bleue, sinon elle sera transparente.
    /// Cela permet de mettre l'option sélectionnée dans un groupe d'options en évidence.
    class ConvertisseurCouleurFond : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return (value.ToString() == parameter.ToString()) ? "#1aff2500" : "#00000000";
        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture) => System.Windows.DependencyProperty.UnsetValue;
    }

    /// <summary>
    /// Permet au InkCanvas de définir son mode d'édition en fonction de l'outil sélectionné.
    /// </summary>
    class ConvertisseurModeEdition : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            switch (value)
            {
                case "lasso":
                    return InkCanvasEditingMode.Select;
                case "efface_segment":
                    return InkCanvasEditingMode.EraseByPoint;
                case "efface_trait":
                    return InkCanvasEditingMode.EraseByStroke;
                case "select":
                case "uml_class":
                case "rectangle":
                case "phase":
                case "artefact":
                case "activity":
                case "role":
                case "asso_uni":
                case "asso_bi":
                case "composition":
                case "heritage":
                case "agregation":
                    return InkCanvasEditingMode.None;
                default:
                    return InkCanvasEditingMode.Ink;
            }
        }
        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture) => System.Windows.DependencyProperty.UnsetValue;
    }
}
