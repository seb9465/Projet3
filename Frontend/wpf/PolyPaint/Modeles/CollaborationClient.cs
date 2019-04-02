using Microsoft.AspNetCore.SignalR.Client;using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Structures;using System;using System.Collections.Generic;using System.Threading.Tasks;using System.Windows;

namespace PolyPaint.Modeles{    public class CollaborationClient    {        public event EventHandler<MessageArgs> DrawReceived;        public event EventHandler<MessageArgs> ResetReceived;        public event EventHandler<MessageArgs> DeleteReceived;        public event EventHandler<MessageArgs> SelectReceived;        public event EventHandler<MessageArgs> DuplicateReceived;        private HubConnection Connection { get; set; }        private List<Channel> Channels { get; set; }        public CollaborationClient()        { }        public async void Initialize(string accessToken)        {            Connection =                new HubConnectionBuilder()                .WithUrl($"{Config.URL}/signalr/collaborative", options =>                {                    options.AccessTokenProvider = () => Task.FromResult(accessToken);                })                .Build();            HandleMessages();            try
            {
                await Connection.StartAsync();            }
            catch (Exception)
            { }        }        private void HandleMessages()
        {
            Connection.On<string>("Draw", (drawViewModelString) =>
            {
                DrawReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Select", (drawViewModels) =>
            {
                SelectReceived?.Invoke(this, new MessageArgs(message: drawViewModels));
            });
            Connection.On<string>("Duplicate", (drawViewModelString) =>
            {
                DuplicateReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Cut", (drawViewModelString) =>
            {
                DeleteReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On("Reset", () =>
            {
                ResetReceived?.Invoke(this, new MessageArgs());
            });
        }        public async void CollaborativeDrawAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Draw(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeSelectAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Select(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeDeleteAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Delete(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeResetAsync()
        {
            try
            {
                await Reset();
            }
            catch (Exception)
            { }
        }
        private async Task Draw(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Draw", JsonConvert.SerializeObject(new ItemsMessage("general", "", drawViewModels)));
            }
            catch (Exception) { }
        }

        private async Task Select(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Select", JsonConvert.SerializeObject(new ItemsMessage("general", "", drawViewModels)));
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

        public async Task Delete(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Cut", JsonConvert.SerializeObject(new ItemsMessage("general", "", drawViewModels)));
            }
            catch (Exception) { }
        }

        public async Task Reset()
        {
            try
            {
                await Connection.InvokeAsync("Reset");
            }
            catch (Exception) { }
        }
    }
}