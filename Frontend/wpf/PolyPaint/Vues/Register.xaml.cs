using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PolyPaint.VueModeles;

namespace PolyPaint.Vues
{
    public partial class Register : Window
    {
        public Register()
        {
            InitializeComponent();
        }

        private void BackBtn_Click(object sender, RoutedEventArgs e)
        {
            Login login = new Login();
            Application.Current.MainWindow = login;
            Close();
            login.Show();
        }

        private async void Register_Click(object sender, RoutedEventArgs e)
        {

            if (!string.IsNullOrWhiteSpace(firstNameBox.Text) && !string.IsNullOrWhiteSpace(LastNameBox.Text)
                      && !string.IsNullOrWhiteSpace(usernameBox.Text) && !string.IsNullOrWhiteSpace(passwordBox.Password))
            {
                registrationSuccessful.Text = "";
                registrationErrors.Text = "";
                RegistrationViewModel registrationViewModel = new RegistrationViewModel();
                registrationViewModel.Email = EmailAddress.Text;
                registrationViewModel.Username = usernameBox.Text;
                registrationViewModel.Password = passwordBox.Password;
                registrationViewModel.FirstName = firstNameBox.Text;
                registrationViewModel.LastName = LastNameBox.Text;

                string json = JsonConvert.SerializeObject(registrationViewModel);

                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new System.Uri(Config.URL);
                    client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                    StringContent content = new StringContent(json, Encoding.UTF8, "application/json");
                    HttpResponseMessage result = await client.PostAsync("/api/register", content);

                    if (result.StatusCode == System.Net.HttpStatusCode.OK)
                    {
                        registrationSuccessful.Text = "Registration Sucessfull";
                    }
                    else
                    {
                        string error = await result.Content.ReadAsStringAsync();
                        error = error.Substring(1, error.Length - 2);
                        error = error.Replace("},", "};");
                        string[] errors = error.Split(';');

                        for(int i = 0; i < errors.Length; i++)
                        {
                            var jo = JObject.Parse(errors[i]);
                            var id = jo["code"].ToString();
                            if (id == "DuplicateEmail")
                            {
                                registrationErrors.Text += " Email already exists";
                            }
                            else if (id == "DuplicateUserName")
                            {
                                registrationErrors.Text += " Username already exists";
                            }
                        }
                        
                    }
                }
            } else
            {
                registrationErrors.Text = "All fields are required";
                
            }
             
        }

        private void IsEmailValid(object sender, RoutedEventArgs e)
        {
            string input = (sender as TextBox).Text;

            if (!Regex.IsMatch(input, @"^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$"))
            {
                InvalidEmail.Opacity = 100;
                RegisterBtn.IsEnabled = false;
            }
            else
            {
                InvalidEmail.Opacity = 0;
                RegisterBtn.IsEnabled = true;
            }
        }

        private void IsPasswordValid(object sender, RoutedEventArgs e)
        {
            string input = (sender as PasswordBox).Password;

            if (!Regex.IsMatch(input, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,15}$"))
            {
                InvalidPassword.Opacity = 100;
                RegisterBtn.IsEnabled = false;
            }
            else
            {
                InvalidPassword.Opacity = 0;
                RegisterBtn.IsEnabled = true;
            }
        }

    }
}
