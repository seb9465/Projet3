﻿using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Structures;

namespace PolyPaint.Modeles
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
                await Connection.InvokeAsync("Draw", JsonConvert.SerializeObject(new ItemsMessage("general", "", drawViewModels)));
            }
            catch (Exception) { }
        }

        public async Task CollaborativeSelectAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Select", JsonConvert.SerializeObject(new ItemsMessage("general", "", drawViewModels)));
            }
            catch (Exception e) { }
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