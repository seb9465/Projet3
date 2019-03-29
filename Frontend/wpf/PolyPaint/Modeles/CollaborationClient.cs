using Microsoft.AspNetCore.SignalR.Client;using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Structures;using System;using System.Collections.Generic;using System.Threading.Tasks;using System.Windows;

namespace PolyPaint.Modeles{    class CollaborationClient    {        public event EventHandler<MessageArgs> MessageReceived;        public event EventHandler<MessageArgs> DrawReceived;        public event EventHandler<MessageArgs> ResetReceived;        public event EventHandler<MessageArgs> DeleteReceived;        public event EventHandler<MessageArgs> SelectReceived;        public event EventHandler<MessageArgs> DuplicateReceived;        public event EventHandler<MessageArgs> DisconnectedFromChannelSender;        private HubConnection Connection { get; set; }        private List<Channel> Channels { get; set; }        public CollaborationClient()        { }        public async void Initialize(string accessToken)        {            Connection =                new HubConnectionBuilder()                .WithUrl($"{Config.URL}/signalr/collaborative", options =>                {                    options.AccessTokenProvider = () => Task.FromResult(accessToken);                })                .Build();            HandleMessages();            await Connection.StartAsync();        }        private void HandleMessages()
        {
            Connection.On<string>("Draw", (drawViewModelString) =>
            {
                DrawReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Select", (selectViewModel) =>
            {
                SelectReceived?.Invoke(this, new MessageArgs(message: selectViewModel));
            });
            Connection.On<string>("Duplicate", (drawViewModelString) =>
            {
                DuplicateReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Delete", (drawViewModelString) =>
            {
                DeleteReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On("Reset", () =>
            {
                ResetReceived?.Invoke(this, new MessageArgs());
            });
        }
        public async Task CollaborativeDrawAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Draw", JsonConvert.SerializeObject(drawViewModels));
            }
            catch (Exception) { }
        }

        public async Task CollaborativeSelectAsync(SelectViewModel selectViewModel)
        {
            try
            {
                await Connection.InvokeAsync("Select", selectViewModel);
            }
            catch (Exception) { }
        }

        public async Task CollaborativeDuplicateAsync()
        {
            object o = Clipboard.GetDataObject();

            try
            {
                await Connection.InvokeAsync("Duplicate");
            }
            catch (Exception) { }
        }

        public async Task CollaborativeDeleteAsync()
        {
            try
            {
                await Connection.InvokeAsync("Delete");
            }
            catch (Exception) { }
        }

        public async Task CollaborativeResetAsync()
        {
            try
            {
                await Connection.InvokeAsync("Reset", "general");
            }
            catch (Exception) { }
        }
    }
}