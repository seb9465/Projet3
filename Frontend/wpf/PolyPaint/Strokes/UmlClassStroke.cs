﻿using PolyPaint.Utilitaires;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Linq;

namespace PolyPaint.Strokes
{
    public class UmlClassStroke : AbstractShapeStroke
    {
        public ObservableCollection<Property> Properties { get; set; }
        public ObservableCollection<Method> Methods { get; set; }

        public RelayCommand<string> AddProperty { get; set; }
        public RelayCommand<string> AddMethod { get; set; }
        public RelayCommand<string> RemoveFromProperties { get; set; }
        public RelayCommand<string> RemoveFromMethods { get; set; }

        public UmlClassStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage)
            : base(pts, surfaceDessin, "Class", couleurBordure, couleurRemplissage)
        {
            Properties = new ObservableCollection<Property>();
            Methods = new ObservableCollection<Method>();

            AddProperty = new RelayCommand<string>(addProperty);
            AddMethod = new RelayCommand<string>(addMethod);
            RemoveFromProperties = new RelayCommand<string>(removeFromProperties);
            RemoveFromMethods = new RelayCommand<string>(removeFromMethods);
        }

        protected override void DrawCore(DrawingContext drawingContext, DrawingAttributes drawingAttributes)
        {
            if (drawingContext == null)
            {
                throw new ArgumentNullException("drawingContext");
            }
            if (null == drawingAttributes)
            {
                throw new ArgumentNullException("drawingAttributes");
            }

            TopLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            Width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            Height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            drawingContext.DrawRectangle(Fill, Border, new Rect(TopLeft, new Point(TopLeft.X + Width, TopLeft.Y + Height)));
            if (IsDrawingDone)
                DrawText(drawingContext);
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext)
        {
            var nextHeight = TopLeft.Y + 10;

            drawingContext.DrawText(Title, new Point(TopLeft.X + 10, nextHeight));
            nextHeight += 10 + Title.Height;
            drawingContext.DrawLine(Border, new Point(TopLeft.X, nextHeight), new Point(TopLeft.X + Width, nextHeight));
            nextHeight += 10;
            for (int i = 0; i < Properties.Count; i++)
            {
                var tempFt = new FormattedText($"{Properties[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
                drawingContext.DrawText(tempFt, new Point(TopLeft.X + 10, nextHeight));
                nextHeight += 10 + tempFt.Height;
            }
            drawingContext.DrawLine(Border, new Point(TopLeft.X, nextHeight), new Point(TopLeft.X + Width, nextHeight));
            nextHeight += 10;
            for (int i = 0; i < Methods.Count; i++)
            {
                var tempFt = new FormattedText($"{Methods[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
                drawingContext.DrawText(tempFt, new Point(TopLeft.X + 10, nextHeight));
                nextHeight += 10 + tempFt.Height;
            }
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(TopLeft.X + Width / 2, TopLeft.Y);
            AnchorPoints[1] = new Point(TopLeft.X + Width / 2, TopLeft.Y + Height);
            AnchorPoints[2] = new Point(TopLeft.X + Width, TopLeft.Y + Height / 2);
            AnchorPoints[3] = new Point(TopLeft.X, TopLeft.Y + Height / 2);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);
        }

        private void addProperty(string bidon)
        {
            Properties.Add(new Property("NewProperty"));
            ProprieteModifiee("Properties");
        }

        private void addMethod(string bidon)
        {
            Methods.Add(new Method("NewMethod"));
            ProprieteModifiee("Methods");
        }

        private void removeFromProperties(string prop)
        {
            Properties.Remove(Properties.FirstOrDefault(x => x.Title == prop));
            ProprieteModifiee("Properties");
        }

        private void removeFromMethods(string method)
        {
            Methods.Remove(Methods.FirstOrDefault(x => x.Title == method));
            ProprieteModifiee("Methods");
        }
    }

    public class Property : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private string _title { get; set; }
        public string Title
        {
            get { return _title; }
            set { _title = value; ProprieteModifiee(); }
        }

        public Property(string title)
        {
            Title = title;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class Method : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private string _title { get; set; }
        public string Title
        {
            get { return _title; }
            set { _title = value; ProprieteModifiee(); }
        }

        public Method(string title)
        {
            Title = title;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
