/*
* Copyright (C) 2014 Andre Kupka, Richard Stromer
*
* This file is part of Sliderule.
*
* Sliderule is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* any later version.
* Sliderule is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Sliderule. If not, see <http://www.gnu.org/licenses/>.
*/

namespace Sliderule {
    public class Application : Granite.Application {
        construct {
            program_name = "Sliderule";
            exec_name = "sliderule";
            app_years = "2014";
            app_icon = "application-default-icon";

            about_authors = {"Andre Kupka, Richard Stromer"};
            about_documenters = {};
            about_artists = {};
            about_comments = "";
            about_license_type = Gtk.License.GPL_3_0;
        }
    }
}
