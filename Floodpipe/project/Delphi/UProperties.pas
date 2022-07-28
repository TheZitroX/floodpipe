{
    file:       UProperties.pas
    author:     John Lienau
    title:      Default properties for Floodpipe
    version:    v1.0
    date:       28.07.2022
    copyright:  Copyright (c) 2022

    brief:      Best to not change the values of the constants
}

unit UProperties;
    interface
        uses
            sysutils;

        const
            // window
                MAIN_FORM_WIDTH = 800;
                MAIN_FORM_HEIGHT = 450;
                // aspect ratio 9 / 16
                MAIN_FORM_ASPECT_RATIO = MAIN_FORM_HEIGHT / MAIN_FORM_WIDTH;

    implementation
    end.