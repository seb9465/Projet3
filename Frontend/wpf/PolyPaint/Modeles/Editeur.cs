﻿using PolyPaint.Common.Collaboration;
using PolyPaint.Strokes;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Media;

namespace PolyPaint.Modeles
{
    /// <summary>
    /// Modélisation de l'éditeur.
    /// Contient ses différents états et propriétés ainsi que la logique
    /// qui régis son fonctionnement.
    /// </summary>
    class Editeur : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public StrokeCollection traits = new StrokeCollection();
        private StrokeCollection traitsRetires = new StrokeCollection();
        public StrokeCollection SelectedStrokes { get; set; } = new StrokeCollection();
        // Outil actif dans l'éditeur
        private string outilSelectionne = "";
        public string OutilSelectionne
        {
            get { return outilSelectionne; }
            set { outilSelectionne = value; ProprieteModifiee(); }
        }

        // Forme de la pointe du crayon
        private string pointeSelectionnee = "ronde";
        public string PointeSelectionnee
        {
            get { return pointeSelectionnee; }
            set
            {
                pointeSelectionnee = value;
                ProprieteModifiee();
            }
        }

        // Couleur des traits tracés par le crayon.
        private string couleurSelectionneeBordure = "#FF000000";
        public string CouleurSelectionneeBordure
        {
            get { return couleurSelectionneeBordure; }
            // Lorsqu'on sélectionne une couleur c'est généralement pour ensuite dessiner un trait.
            // C'est pourquoi lorsque la couleur est changée, l'outil est automatiquement changé pour le crayon.
            set
            {
                couleurSelectionneeBordure = value;

                if (couleurSelectionneeBordure != "")
                {
                    foreach (AbstractShapeStroke stroke in SelectedStrokes.Where(x => x is AbstractShapeStroke))
                    {
                        stroke.SetBorderColor(value);
                    }
                    foreach (AbstractLineStroke stroke in SelectedStrokes.Where(x => x is AbstractLineStroke))
                    {
                        stroke.SetBorderColor(value);
                    }
                }

                ProprieteModifiee();
                ProprieteModifiee("CouleurSelectionneeBordureConverted");
            }
        }

        public string CouleurSelectionneeBordureConverted
        {
            get
            {
                return couleurSelectionneeBordure;
            }
        }

        // Couleur des traits tracés par le crayon.
        private string couleurSelectionneeRemplissage = "#FFFFFFFF";
        public string CouleurSelectionneeRemplissage
        {
            get { return couleurSelectionneeRemplissage; }
            // Lorsqu'on sélectionne une couleur c'est généralement pour ensuite dessiner un trait.
            // C'est pourquoi lorsque la couleur est changée, l'outil est automatiquement changé pour le crayon.
            set
            {
                couleurSelectionneeRemplissage = value;

                if (couleurSelectionneeRemplissage != "")
                {
                    foreach (AbstractShapeStroke stroke in SelectedStrokes.Where(x => x is AbstractShapeStroke))
                    {
                        stroke.SetFillColor(value);
                    }
                }

                ProprieteModifiee();
                ProprieteModifiee("CouleurSelectionneeRemplissageConverted");
            }
        }

        public string CouleurSelectionneeRemplissageConverted
        {
            get
            {
                return couleurSelectionneeRemplissage;
            }
        }

        // Grosseur des traits tracés par le crayon.
        private int tailleTrait = 2;
        public int TailleTrait
        {
            get { return tailleTrait; }
            // Lorsqu'on sélectionne une taille de trait c'est généralement pour ensuite dessiner un trait.
            // C'est pourquoi lorsque la taille est changée, l'outil est automatiquement changé pour le crayon.
            set
            {
                tailleTrait = value;
                ProprieteModifiee();
            }
        }

        /// <summary>
        /// Appelee lorsqu'une propriété d'Editeur est modifiée.
        /// Un évènement indiquant qu'une propriété a été modifiée est alors émis à partir d'Editeur.
        /// L'évènement qui contient le nom de la propriété modifiée sera attrapé par VueModele qui pourra
        /// alors prendre action en conséquence.
        /// </summary>
        /// <param name="propertyName">Nom de la propriété modifiée.</param>
        protected void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        // S'il y a au moins 1 trait sur la surface, il est possible d'exécuter Empiler.
        public bool PeutEmpiler(object o) => (traits.Count > 0);
        // On retire le trait le plus récent de la surface de dessin et on le place sur une pile.
        public void Empiler(object o)
        {
            try
            {
                Stroke trait = traits.Last();
                traitsRetires.Add(trait);
                traits.Remove(trait);
            }
            catch { }

        }

        // S'il y a au moins 1 trait sur la pile de traits retirés, il est possible d'exécuter Depiler.
        public bool PeutDepiler(object o) => (traitsRetires.Count > 0);
        // On retire le trait du dessus de la pile de traits retirés et on le place sur la surface de dessin.
        public void Depiler(object o)
        {
            try
            {
                Stroke trait = traitsRetires.Last();
                traits.Add(trait);
                traitsRetires.Remove(trait);
            }
            catch { }
        }

        // On assigne une nouvelle forme de pointe passée en paramètre.
        public void ChoisirPointe(string pointe) => PointeSelectionnee = pointe;

        // L'outil actif devient celui passé en paramètre.
        public void ChoisirOutil(string outil) => OutilSelectionne = outil;

        // On vide la surface de dessin de tous ses traits.
        public void Reinitialiser(object o) => traits.Clear();

        public void SelectItemOffline(InkCanvas surfaceDessin, Point mouseLeftDownPoint)
        {
            InkCanvasEditingMode all = surfaceDessin.EditingMode;

            // We travel the StrokeCollection inversely to select the first plan item first
            // if some items overlap.
            StrokeCollection strokeToSelect = new StrokeCollection();
            for (int i = traits.Count - 1; i >= 0; i--)
            {
                Rect box = traits[i].GetBounds();
                if (mouseLeftDownPoint.X >= box.Left && mouseLeftDownPoint.X <= box.Right &&
                    mouseLeftDownPoint.Y <= box.Bottom && mouseLeftDownPoint.Y >= box.Top)
                {
                    strokeToSelect.Add(traits[i]);
                    surfaceDessin.Select(strokeToSelect);

                    break;
                }
            }
        }

        public void SelectItemOnline(InkCanvas surfaceDessin, SelectViewModel selectViewModel, string username)
        {
            InkCanvasEditingMode all = surfaceDessin.EditingMode;

            // We travel the StrokeCollection inversely to select the first plan item first
            // if some items overlap.
            StrokeCollection strokeToSelect = new StrokeCollection();
            for (int i = traits.Count - 1; i >= 0; i--)
            {
                Rect box = traits[i].GetBounds();
                if (selectViewModel.MouseLeftDownPointX >= box.Left && selectViewModel.MouseLeftDownPointX <= box.Right &&
                    selectViewModel.MouseLeftDownPointY <= box.Bottom && selectViewModel.MouseLeftDownPointY >= box.Top)
                {
                    if (username == selectViewModel.Owner)
                    {
                        //strokes[i].DrawingAttributes.Color = Colors.Black;
                    }
                    strokeToSelect.Add(traits[i]);
                    surfaceDessin.Select(strokeToSelect);
                    break;
                }
            }
        }
    }
}