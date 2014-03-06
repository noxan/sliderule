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
class Application : Granite.Application {
    construct {
        program_name = "Sliderule";
        exec_name = "sliderule";
        app_years = "2014";
        app_icon = "application-default-icon";

        about_authors = {"Andre Kupka", "Richard Stromer", null};
        about_documenters = {};
        about_artists = {};
        about_comments = "";
        about_license_type = Gtk.License.GPL_3_0;
    }

    private Gtk.Window window;

    protected override void activate () {
        window = new Gtk.Window ();
        window.set_application (this);

        Gtk.Box container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        Gtk.Grid grid = new Gtk.Grid ();

        string[][] labelsMatrix = {{"=", ".", "0"}, {"1", "2", "3"}, {"4", "5", "6"}, {"7", "8", "9"}};
        for (int y = 0; y < labelsMatrix.length; y++) {
            string[] labels = labelsMatrix[y];
            for (int x = 0; x < labels.length; x++) {
                var button = new Gtk.Button.with_label (labels[x]);
                grid.attach (button, x, y, 1, 1);
            }
        }

        container.add (grid);

        window.add(container);

        window.show_all ();
    }
}
}
