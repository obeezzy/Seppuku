pragma Singleton
import QtQuick 2.9
import Bacon2D 1.0

// ----------- Prefixes --------------
// k = Box2D Category
// g = Group index
// z = position on z axis

Item {
    id: global
    // const static variables
    readonly property real degToRad: Math.PI / 180
    readonly property int levelCount: 3

    readonly property string defaultFont: defaultFontLoader.name
    readonly property string headerFont: defaultFontLoader.name
    readonly property string hintFont: hintFontLoader.name
    readonly property string tutorFont: tutorFontLoader.name
    readonly property string iconFont: iconFontLoader.name
    readonly property var icons: icons
    readonly property var paths: paths

    property var checkpointState: {
        "level": 0, "pos": Qt.point(-1, -1)
    }

    property var settings: Settings {
        id: settings
        property int highScore: 0
        property bool noSound: false
        property real sfxVolume: .4
        property real bgmVolume: .4

        property int currentLevel: global.currentLevel
    }
    property string currentPopup: ""
    property var gameWindow: undefined

    // Is message being shown to the user?
    property bool messageVisible: false

    readonly property int defaultWidth: 800
    readonly property int defaultHeight: 600
    readonly property bool isMobile: {
        switch(Qt.platform.os) {
            case "android":
            case "blackberry":
            case "ios":
                true;
                break;
            case "osx":
            case "linux":
            case "unix":
            case "windows":
            case "wince":
                false;
                break;
        }
    }

    /************************* UTILITY OBJECTS *******************************************/
    // Ignore collisions
    readonly property int kIntangible: Box.None

    // Hit everything
    readonly property int kAll: Box.All

    // Enemy's main body area
    readonly property int kEnemy: Box.Category1

    // Actor's main body area
    readonly property int kActor: Box.Category2

    /****************** INVENTORIES ***********************/
    readonly property int kCollectible: Box.Category3

    /****************** OBSTACLES ********************/
    readonly property int kObstacle: Box.Category4

    /***************** OBJECTS FOR UNDERCOVER *************/
    readonly property int kCovert: Box.Category5

    // Colliding with ground and walls
    readonly property int kLadder: Box.Category6

    // Colliding with signs
    // NOTE: put under "usables" category
    readonly property int kInteractive: Box.Category7

    // Colliding with pipes
    readonly property int kHoverArea: Box.Category8

    // Colliding with the bottom of the scene
    readonly property int kLava: Box.Category9

    // Colliding with doors
    readonly property int kDoor: Box.Category10

    // Rigid bodies
    readonly property int kWall: Box.Category14
    readonly property int kGround: Box.Category15
    readonly property int kGroundTop: Box.Category16



    /************** GROUP INDEXES **********************/
    readonly property int gActorGroupIndex: 1


    // Z POSITIONS
    readonly property int zActor: 10
    readonly property int zInteractive: zActor - 1
    readonly property int zActorDisguised: 0
    readonly property int zDisguise: 4
    readonly property int zEnemy: 1
    readonly property int zHUD: 49
    readonly property int zTutor: zHUD
    readonly property int zCollectible: zActor + 1
    readonly property int zCannonBullet: -1
    readonly property int zLaser: 11
    readonly property int zLava: 30
    readonly property int zCamera: 100
    readonly property int zPopup: 101

    /********* END GROUP INDEXES ***************************/

    /************** GLOBAL VARIABLES **********************/
    property int currentLevel: 1
    /************** END GLOBAL VARIABLES *********************/


    /*************** FONT LOADERS ****************************/
    FontLoader {
        id: defaultFontLoader
        source: paths.fonts + "matura/MATURASC.TTF"
    }

    FontLoader {
        id: tutorFontLoader
        source: paths.fonts + "gabriola/Gabriola.ttf"
    }

    FontLoader {
        id: hintFontLoader
        source: paths.fonts + "lobster/Lobster.ttf"
    }

    FontLoader {
        id: iconFontLoader
        source: paths.fonts + "fontawesome/fontawesome-webfont.ttf"
    }

    /*********** END FONT LOADERS ****************************/


    QtObject {
        id: icons
        readonly property string fa_adjust                  : "\uf042"
        readonly property string fa_adn                     : "\uf170"
        readonly property string fa_align_center            : "\uf037"
        readonly property string fa_align_justify           : "\uf039"
        readonly property string fa_align_left              : "\uf036"
        readonly property string fa_align_right             : "\uf038"
        readonly property string fa_ambulance               : "\uf0f9"
        readonly property string fa_anchor                  : "\uf13d"
        readonly property string fa_android                 : "\uf17b"
        readonly property string fa_angellist               : "\uf209"
        readonly property string fa_angle_double_down       : "\uf103"
        readonly property string fa_angle_double_left       : "\uf100"
        readonly property string fa_angle_double_right      : "\uf101"
        readonly property string fa_angle_double_up         : "\uf102"
        readonly property string fa_angle_down              : "\uf107"
        readonly property string fa_angle_left              : "\uf104"
        readonly property string fa_angle_right             : "\uf105"
        readonly property string fa_angle_up                : "\uf106"
        readonly property string fa_apple                   : "\uf179"
        readonly property string fa_archive                 : "\uf187"
        readonly property string fa_area_chart              : "\uf1fe"
        readonly property string fa_arrow_circle_down       : "\uf0ab"
        readonly property string fa_arrow_circle_left       : "\uf0a8"
        readonly property string fa_arrow_circle_o_down     : "\uf01a"
        readonly property string fa_arrow_circle_o_left     : "\uf190"
        readonly property string fa_arrow_circle_o_right    : "\uf18e"
        readonly property string fa_arrow_circle_o_up       : "\uf01b"
        readonly property string fa_arrow_circle_right      : "\uf0a9"
        readonly property string fa_arrow_circle_up         : "\uf0aa"
        readonly property string fa_arrow_down              : "\uf063"
        readonly property string fa_arrow_left              : "\uf060"
        readonly property string fa_arrow_right             : "\uf061"
        readonly property string fa_arrow_up                : "\uf062"
        readonly property string fa_arrows                  : "\uf047"
        readonly property string fa_arrows_alt              : "\uf0b2"
        readonly property string fa_arrows_h                : "\uf07e"
        readonly property string fa_arrows_v                : "\uf07d"
        readonly property string fa_asterisk                : "\uf069"
        readonly property string fa_at                      : "\uf1fa"
        readonly property string fa_automobile              : "\uf1b9"
        readonly property string fa_backward                : "\uf04a"
        readonly property string fa_ban                     : "\uf05e"
        readonly property string fa_bank                    : "\uf19c"
        readonly property string fa_bar_chart_o             : "\uf080"
        readonly property string fa_barcode                 : "\uf02a"
        readonly property string fa_bars                    : "\uf0c9"
        readonly property string fa_beer                    : "\uf0fc"
        readonly property string fa_behance                 : "\uf1b4"
        readonly property string fa_behance_square          : "\uf1b5"
        readonly property string fa_bell                    : "\uf0f3"
        readonly property string fa_bell_o                  : "\uf0a2"
        readonly property string fa_bell_slash              : "\uf1f6"
        readonly property string fa_bell_slash_o            : "\uf1f7"
        readonly property string fa_bicycle                 : "\uf206"
        readonly property string fa_binoculars              : "\uf1e5"
        readonly property string fa_birthday_cake           : "\uf1fd"
        readonly property string fa_bitbucket               : "\uf171"
        readonly property string fa_bitbucket_square        : "\uf172"
        readonly property string fa_bitcoin                 : "\uf15a"
        readonly property string fa_bold                    : "\uf032"
        readonly property string fa_bolt                    : "\uf0e7"
        readonly property string fa_bomb                    : "\uf1e2"
        readonly property string fa_book                    : "\uf02d"
        readonly property string fa_bookmark                : "\uf02e"
        readonly property string fa_bookmark_o              : "\uf097"
        readonly property string fa_briefcase               : "\uf0b1"
        readonly property string fa_btc                     : "\uf15a"
        readonly property string fa_bug                     : "\uf188"
        readonly property string fa_building                : "\uf1ad"
        readonly property string fa_building_o              : "\uf0f7"
        readonly property string fa_bullhorn                : "\uf0a1"
        readonly property string fa_bullseye                : "\uf140"
        readonly property string $fa_bus                    : "\uf207"
        readonly property string fa_cab                     : "\uf1ba"
        readonly property string $fa_calculator             : "\uf1ec"
        readonly property string fa_calendar                : "\uf073"
        readonly property string fa_calendar_o              : "\uf133"
        readonly property string fa_camera                  : "\uf030"
        readonly property string fa_camera_retro            : "\uf083"
        readonly property string fa_car                     : "\uf1b9"
        readonly property string fa_caret_down              : "\uf0d7"
        readonly property string fa_caret_left              : "\uf0d9"
        readonly property string fa_caret_right             : "\uf0da"
        readonly property string fa_caret_square_o_down     : "\uf150"
        readonly property string fa_caret_square_o_left     : "\uf191"
        readonly property string fa_caret_square_o_right    : "\uf152"
        readonly property string fa_caret_square_o_up       : "\uf151"
        readonly property string fa_caret_up                : "\uf0d8"
        readonly property string fa_cc                      : "\uf20a"
        readonly property string fa_cc_amex                 : "\uf1f3"
        readonly property string fa_cc_discover             : "\uf1f2"
        readonly property string fa_cc_mastercard           : "\uf1f1"
        readonly property string fa_cc_paypal               : "\uf1f4"
        readonly property string fa_cc_stripe               : "\uf1f5"
        readonly property string fa_cc_visa                 : "\uf1f0"
        readonly property string fa_certificate             : "\uf0a3"
        readonly property string fa_chain                   : "\uf0c1"
        readonly property string fa_chain_broken            : "\uf127"
        readonly property string fa_check                   : "\uf00c"
        readonly property string fa_check_circle            : "\uf058"
        readonly property string fa_check_circle_o          : "\uf05d"
        readonly property string fa_check_square            : "\uf14a"
        readonly property string fa_check_square_o          : "\uf046"
        readonly property string fa_chevron_circle_down     : "\uf13a"
        readonly property string fa_chevron_circle_left     : "\uf137"
        readonly property string fa_chevron_circle_right    : "\uf138"
        readonly property string fa_chevron_circle_up       : "\uf139"
        readonly property string fa_chevron_down            : "\uf078"
        readonly property string fa_chevron_left            : "\uf053"
        readonly property string fa_chevron_right           : "\uf054"
        readonly property string fa_chevron_up              : "\uf077"
        readonly property string fa_child                   : "\uf1ae"
        readonly property string fa_circle                  : "\uf111"
        readonly property string fa_circle_o                : "\uf10c"
        readonly property string fa_circle_o_notch          : "\uf1ce"
        readonly property string fa_circle_thin             : "\uf1db"
        readonly property string fa_clipboard               : "\uf0ea"
        readonly property string fa_clock_o                 : "\uf017"
        readonly property string fa_cloud                   : "\uf0c2"
        readonly property string fa_cloud_download          : "\uf0ed"
        readonly property string fa_cloud_upload            : "\uf0ee"
        readonly property string fa_cny                     : "\uf157"
        readonly property string fa_code                    : "\uf121"
        readonly property string fa_code_fork               : "\uf126"
        readonly property string fa_codepen                 : "\uf1cb"
        readonly property string fa_coffee                  : "\uf0f4"
        readonly property string fa_cog                     : "\uf013"
        readonly property string fa_cogs                    : "\uf085"
        readonly property string fa_columns                 : "\uf0db"
        readonly property string fa_comment                 : "\uf075"
        readonly property string fa_comment_o               : "\uf0e5"
        readonly property string fa_comments                : "\uf086"
        readonly property string fa_comments_o              : "\uf0e6"
        readonly property string fa_compass                 : "\uf14e"
        readonly property string fa_compress                : "\uf066"
        readonly property string fa_copy                    : "\uf0c5"
        readonly property string fa_copyright               : "\uf1f9"
        readonly property string fa_credit_card             : "\uf09d"
        readonly property string fa_crop                    : "\uf125"
        readonly property string fa_crosshairs              : "\uf05b"
        readonly property string fa_css3                    : "\uf13c"
        readonly property string fa_cube                    : "\uf1b2"
        readonly property string fa_cubes                   : "\uf1b3"
        readonly property string fa_cut                     : "\uf0c4"
        readonly property string fa_cutlery                 : "\uf0f5"
        readonly property string fa_dashboard               : "\uf0e4"
        readonly property string fa_database                : "\uf1c0"
        readonly property string fa_dedent                  : "\uf03b"
        readonly property string fa_delicious               : "\uf1a5"
        readonly property string fa_desktop                 : "\uf108"
        readonly property string fa_deviantart              : "\uf1bd"
        readonly property string fa_digg                    : "\uf1a6"
        readonly property string fa_dollar                  : "\uf155"
        readonly property string fa_dot_circle_o            : "\uf192"
        readonly property string fa_download                : "\uf019"
        readonly property string fa_dribbble                : "\uf17d"
        readonly property string fa_dropbox                 : "\uf16b"
        readonly property string fa_drupal                  : "\uf1a9"
        readonly property string fa_edit                    : "\uf044"
        readonly property string fa_eject                   : "\uf052"
        readonly property string fa_ellipsis_h              : "\uf141"
        readonly property string fa_ellipsis_v              : "\uf142"
        readonly property string fa_empire                  : "\uf1d1"
        readonly property string fa_envelope                : "\uf0e0"
        readonly property string fa_envelope_o              : "\uf003"
        readonly property string fa_envelope_square         : "\uf199"
        readonly property string fa_eraser                  : "\uf12d"
        readonly property string fa_eur                     : "\uf153"
        readonly property string fa_euro                    : "\uf153"
        readonly property string fa_exchange                : "\uf0ec"
        readonly property string fa_exclamation             : "\uf12a"
        readonly property string fa_exclamation_circle      : "\uf06a"
        readonly property string fa_exclamation_triangle    : "\uf071"
        readonly property string fa_expand                  : "\uf065"
        readonly property string fa_external_link           : "\uf08e"
        readonly property string fa_external_link_square    : "\uf14c"
        readonly property string fa_eye                     : "\uf06e"
        readonly property string fa_eye_slash               : "\uf070"
        readonly property string fa_eyedropper              : "\uf1fb"
        readonly property string fa_facebook                : "\uf09a"
        readonly property string fa_facebook_square         : "\uf082"
        readonly property string fa_fast_backward           : "\uf049"
        readonly property string fa_fast_forward            : "\uf050"
        readonly property string fa_fax                     : "\uf1ac"
        readonly property string fa_female                  : "\uf182"
        readonly property string fa_fighter_jet             : "\uf0fb"
        readonly property string fa_file                    : "\uf15b"
        readonly property string fa_file_archive_o          : "\uf1c6"
        readonly property string fa_file_audio_o            : "\uf1c7"
        readonly property string fa_file_code_o             : "\uf1c9"
        readonly property string fa_file_excel_o            : "\uf1c3"
        readonly property string fa_file_image_o            : "\uf1c5"
        readonly property string fa_file_movie_o            : "\uf1c8"
        readonly property string fa_file_o                  : "\uf016"
        readonly property string fa_file_pdf_o              : "\uf1c1"
        readonly property string fa_file_photo_o            : "\uf1c5"
        readonly property string fa_file_picture_o          : "\uf1c5"
        readonly property string fa_file_powerpoint_o       : "\uf1c4"
        readonly property string fa_file_sound_o            : "\uf1c7"
        readonly property string fa_file_text               : "\uf15c"
        readonly property string fa_file_text_o             : "\uf0f6"
        readonly property string fa_file_video_o            : "\uf1c8"
        readonly property string fa_file_word_o             : "\uf1c2"
        readonly property string fa_file_zip_o              : "\uf1c6"
        readonly property string fa_files_o                 : "\uf0c5"
        readonly property string fa_film                    : "\uf008"
        readonly property string fa_filter                  : "\uf0b0"
        readonly property string fa_fire                    : "\uf06d"
        readonly property string fa_fire_extinguisher       : "\uf134"
        readonly property string fa_flag                    : "\uf024"
        readonly property string fa_flag_checkered          : "\uf11e"
        readonly property string fa_flag_o                  : "\uf11d"
        readonly property string fa_flash                   : "\uf0e7"
        readonly property string fa_flask                   : "\uf0c3"
        readonly property string fa_flickr                  : "\uf16e"
        readonly property string fa_floppy_o                : "\uf0c7"
        readonly property string fa_folder                  : "\uf07b"
        readonly property string fa_folder_o                : "\uf114"
        readonly property string fa_folder_open             : "\uf07c"
        readonly property string fa_folder_open_o           : "\uf115"
        readonly property string fa_font                    : "\uf031"
        readonly property string fa_forward                 : "\uf04e"
        readonly property string fa_foursquare              : "\uf180"
        readonly property string fa_frown_o                 : "\uf119"
        readonly property string fa_futbol_o                : "\uf1e3"
        readonly property string fa_gamepad                 : "\uf11b"
        readonly property string fa_gavel                   : "\uf0e3"
        readonly property string fa_gbp                     : "\uf154"
        readonly property string fa_ge                      : "\uf1d1"
        readonly property string fa_gear                    : "\uf013"
        readonly property string fa_gears                   : "\uf085"
        readonly property string fa_gift                    : "\uf06b"
        readonly property string fa_git                     : "\uf1d3"
        readonly property string fa_git_square              : "\uf1d2"
        readonly property string fa_github                  : "\uf09b"
        readonly property string fa_github_alt              : "\uf113"
        readonly property string fa_github_square           : "\uf092"
        readonly property string fa_gittip                  : "\uf184"
        readonly property string fa_glass                   : "\uf000"
        readonly property string fa_globe                   : "\uf0ac"
        readonly property string fa_google                  : "\uf1a0"
        readonly property string fa_google_plus             : "\uf0d5"
        readonly property string fa_google_plus_square      : "\uf0d4"
        readonly property string fa_google_wallet           : "\uf1ee"
        readonly property string fa_graduation_cap          : "\uf19d"
        readonly property string fa_group                   : "\uf0c0"
        readonly property string fa_h_square                : "\uf0fd"
        readonly property string fa_hacker_news             : "\uf1d4"
        readonly property string fa_hand_o_down             : "\uf0a7"
        readonly property string fa_hand_o_left             : "\uf0a5"
        readonly property string fa_hand_o_right            : "\uf0a4"
        readonly property string fa_hand_o_up               : "\uf0a6"
        readonly property string fa_hdd_o                   : "\uf0a0"
        readonly property string fa_header                  : "\uf1dc"
        readonly property string fa_headphones              : "\uf025"
        readonly property string fa_heart                   : "\uf004"
        readonly property string fa_heart_o                 : "\uf08a"
        readonly property string fa_history                 : "\uf1da"
        readonly property string fa_home                    : "\uf015"
        readonly property string fa_hospital_o              : "\uf0f8"
        readonly property string fa_hourglass_o             : "\uf254"
        readonly property string fa_html5                   : "\uf13b"
        readonly property string fa_ils                     : "\uf20b"
        readonly property string fa_image                   : "\uf03e"
        readonly property string fa_inbox                   : "\uf01c"
        readonly property string fa_indent                  : "\uf03c"
        readonly property string fa_info                    : "\uf129"
        readonly property string fa_info_circle             : "\uf05a"
        readonly property string fa_inr                     : "\uf156"
        readonly property string fa_instagram               : "\uf16d"
        readonly property string fa_institution             : "\uf19c"
        readonly property string fa_ioxhost                 : "\uf208"
        readonly property string fa_italic                  : "\uf033"
        readonly property string fa_joomla                  : "\uf1aa"
        readonly property string fa_jpy                     : "\uf157"
        readonly property string fa_jsfiddle                : "\uf1cc"
        readonly property string fa_key                     : "\uf084"
        readonly property string fa_keyboard_o              : "\uf11c"
        readonly property string fa_krw                     : "\uf159"
        readonly property string fa_language                : "\uf1ab"
        readonly property string fa_laptop                  : "\uf109"
        readonly property string fa_lastfm                  : "\uf202"
        readonly property string fa_lastfm_square           : "\uf203"
        readonly property string fa_leaf                    : "\uf06c"
        readonly property string fa_legal                   : "\uf0e3"
        readonly property string fa_lemon_o                 : "\uf094"
        readonly property string fa_level_down              : "\uf149"
        readonly property string fa_level_up                : "\uf148"
        readonly property string fa_life_bouy               : "\uf1cd"
        readonly property string fa_life_buoy               : "\uf1cd"
        readonly property string fa_life_ring               : "\uf1cd"
        readonly property string fa_life_saver              : "\uf1cd"
        readonly property string fa_lightbulb_o             : "\uf0eb"
        readonly property string fa_line_chart              : "\uf201"
        readonly property string fa_link                    : "\uf0c1"
        readonly property string fa_linkedin                : "\uf0e1"
        readonly property string fa_linkedin_square         : "\uf08c"
        readonly property string fa_linux                   : "\uf17c"
        readonly property string fa_list                    : "\uf03a"
        readonly property string fa_list_alt                : "\uf022"
        readonly property string fa_list_ol                 : "\uf0cb"
        readonly property string fa_list_ul                 : "\uf0ca"
        readonly property string fa_location_arrow          : "\uf124"
        readonly property string fa_lock                    : "\uf023"
        readonly property string fa_long_arrow_down         : "\uf175"
        readonly property string fa_long_arrow_left         : "\uf177"
        readonly property string fa_long_arrow_right        : "\uf178"
        readonly property string fa_long_arrow_up           : "\uf176"
        readonly property string fa_magic                   : "\uf0d0"
        readonly property string fa_magnet                  : "\uf076"
        readonly property string fa_mail_forward            : "\uf064"
        readonly property string fa_mail_reply              : "\uf112"
        readonly property string fa_mail_reply_all          : "\uf122"
        readonly property string fa_male                    : "\uf183"
        readonly property string fa_map_marker              : "\uf041"
        readonly property string fa_maxcdn                  : "\uf136"
        readonly property string fa_meanpath                : "\uf20c"
        readonly property string fa_medkit                  : "\uf0fa"
        readonly property string fa_meh_o                   : "\uf11a"
        readonly property string fa_microphone              : "\uf130"
        readonly property string fa_microphone_slash        : "\uf131"
        readonly property string fa_minus                   : "\uf068"
        readonly property string fa_minus_circle            : "\uf056"
        readonly property string fa_minus_square            : "\uf146"
        readonly property string fa_minus_square_o          : "\uf147"
        readonly property string fa_mobile                  : "\uf10b"
        readonly property string fa_mobile_phone            : "\uf10b"
        readonly property string fa_money                   : "\uf0d6"
        readonly property string fa_moon_o                  : "\uf186"
        readonly property string fa_mortar_board            : "\uf19d"
        readonly property string fa_music                   : "\uf001"
        readonly property string fa_navicon                 : "\uf0c9"
        readonly property string fa_newspaper_o             : "\uf1ea"
        readonly property string fa_openid                  : "\uf19b"
        readonly property string fa_outdent                 : "\uf03b"
        readonly property string fa_pagelines               : "\uf18c"
        readonly property string fa_paint_brush             : "\uf1fc"
        readonly property string fa_paper_plane             : "\uf1d8"
        readonly property string fa_paper_plane_o           : "\uf1d9"
        readonly property string fa_paperclip               : "\uf0c6"
        readonly property string fa_paragraph               : "\uf1dd"
        readonly property string fa_paste                   : "\uf0ea"
        readonly property string fa_pause                   : "\uf04c"
        readonly property string fa_paw                     : "\uf1b0"
        readonly property string fa_paypal                  : "\uf1ed"
        readonly property string fa_pencil                  : "\uf040"
        readonly property string fa_pencil_square           : "\uf14b"
        readonly property string fa_pencil_square_o         : "\uf044"
        readonly property string fa_phone                   : "\uf095"
        readonly property string fa_phone_square            : "\uf098"
        readonly property string fa_photo                   : "\uf03e"
        readonly property string fa_picture_o               : "\uf03e"
        readonly property string fa_pie_chart               : "\uf200"
        readonly property string fa_pied_piper              : "\uf1a7"
        readonly property string fa_pied_piper_alt          : "\uf1a8"
        readonly property string fa_pinterest               : "\uf0d2"
        readonly property string fa_pinterest_square        : "\uf0d3"
        readonly property string fa_plane                   : "\uf072"
        readonly property string fa_play                    : "\uf04b"
        readonly property string fa_play_circle             : "\uf144"
        readonly property string fa_play_circle_o           : "\uf01d"
        readonly property string fa_plug                    : "\uf1e6"
        readonly property string fa_plus                    : "\uf067"
        readonly property string fa_plus_circle             : "\uf055"
        readonly property string fa_plus_square             : "\uf0fe"
        readonly property string fa_plus_square_o           : "\uf196"
        readonly property string fa_power_off               : "\uf011"
        readonly property string fa_print                   : "\uf02f"
        readonly property string fa_puzzle_piece            : "\uf12e"
        readonly property string fa_qq                      : "\uf1d6"
        readonly property string fa_qrcode                  : "\uf029"
        readonly property string fa_question                : "\uf128"
        readonly property string fa_question_circle         : "\uf059"
        readonly property string fa_quote_left              : "\uf10d"
        readonly property string fa_quote_right             : "\uf10e"
        readonly property string fa_ra                      : "\uf1d0"
        readonly property string fa_random                  : "\uf074"
        readonly property string fa_rebel                   : "\uf1d0"
        readonly property string fa_recycle                 : "\uf1b8"
        readonly property string fa_reddit                  : "\uf1a1"
        readonly property string fa_reddit_square           : "\uf1a2"
        readonly property string fa_refresh                 : "\uf021"
        readonly property string fa_remove                  : "\uf00d"
        readonly property string fa_renren                  : "\uf18b"
        readonly property string fa_reorder                 : "\uf0c9"
        readonly property string fa_repeat                  : "\uf01e"
        readonly property string fa_reply                   : "\uf112"
        readonly property string fa_reply_all               : "\uf122"
        readonly property string fa_retweet                 : "\uf079"
        readonly property string fa_rmb                     : "\uf157"
        readonly property string fa_road                    : "\uf018"
        readonly property string fa_rocket                  : "\uf135"
        readonly property string fa_rotate_left             : "\uf0e2"
        readonly property string fa_rotate_right            : "\uf01e"
        readonly property string fa_rouble                  : "\uf158"
        readonly property string fa_rss                     : "\uf09e"
        readonly property string fa_rss_square              : "\uf143"
        readonly property string fa_rub                     : "\uf158"
        readonly property string fa_ruble                   : "\uf158"
        readonly property string fa_rupee                   : "\uf156"
        readonly property string fa_save                    : "\uf0c7"
        readonly property string fa_scissors                : "\uf0c4"
        readonly property string fa_search                  : "\uf002"
        readonly property string fa_search_minus            : "\uf010"
        readonly property string fa_search_plus             : "\uf00e"
        readonly property string fa_send                    : "\uf1d8"
        readonly property string fa_send_o                  : "\uf1d9"
        readonly property string fa_share                   : "\uf064"
        readonly property string fa_share_alt               : "\uf1e0"
        readonly property string fa_share_alt_square        : "\uf1e1"
        readonly property string fa_share_square            : "\uf14d"
        readonly property string fa_share_square_o          : "\uf045"
        readonly property string fa_shekel                  : "\uf20b"
        readonly property string fa_sheqel                  : "\uf20b"
        readonly property string fa_shield                  : "\uf132"
        readonly property string fa_shopping_cart           : "\uf07a"
        readonly property string fa_sign_in                 : "\uf090"
        readonly property string fa_sign_out                : "\uf08b"
        readonly property string fa_signal                  : "\uf012"
        readonly property string fa_sitemap                 : "\uf0e8"
        readonly property string fa_skype                   : "\uf17e"
        readonly property string fa_slack                   : "\uf198"
        readonly property string fa_sliders                 : "\uf1de"
        readonly property string fa_slideshare              : "\uf1e7"
        readonly property string fa_smile_o                 : "\uf118"
        readonly property string fa_soccer_ball_o           : "\uf1e3"
        readonly property string fa_sort                    : "\uf0dc"
        readonly property string fa_sort_alpha_asc          : "\uf15d"
        readonly property string fa_sort_alpha_desc         : "\uf15e"
        readonly property string fa_sort_amount_asc         : "\uf160"
        readonly property string fa_sort_amount_desc        : "\uf161"
        readonly property string fa_sort_asc                : "\uf0de"
        readonly property string fa_sort_desc               : "\uf0dd"
        readonly property string fa_sort_down               : "\uf0dd"
        readonly property string fa_sort_numeric_asc        : "\uf162"
        readonly property string fa_sort_numeric_desc       : "\uf163"
        readonly property string fa_sort_up                 : "\uf0de"
        readonly property string fa_soundcloud              : "\uf1be"
        readonly property string fa_space_shuttle           : "\uf197"
        readonly property string fa_spinner                 : "\uf110"
        readonly property string fa_spoon                   : "\uf1b1"
        readonly property string fa_spotify                 : "\uf1bc"
        readonly property string fa_square                  : "\uf0c8"
        readonly property string fa_square_o                : "\uf096"
        readonly property string fa_stack_exchange          : "\uf18d"
        readonly property string fa_stack_overflow          : "\uf16c"
        readonly property string fa_star                    : "\uf005"
        readonly property string fa_star_half               : "\uf089"
        readonly property string fa_star_half_empty         : "\uf123"
        readonly property string fa_star_half_full          : "\uf123"
        readonly property string fa_star_half_o             : "\uf123"
        readonly property string fa_star_o                  : "\uf006"
        readonly property string fa_steam                   : "\uf1b6"
        readonly property string fa_steam_square            : "\uf1b7"
        readonly property string fa_step_backward           : "\uf048"
        readonly property string fa_step_forward            : "\uf051"
        readonly property string fa_stethoscope             : "\uf0f1"
        readonly property string fa_stop                    : "\uf04d"
        readonly property string fa_strikethrough           : "\uf0cc"
        readonly property string fa_stumbleupon             : "\uf1a4"
        readonly property string fa_stumbleupon_circle      : "\uf1a3"
        readonly property string fa_subscript               : "\uf12c"
        readonly property string fa_suitcase                : "\uf0f2"
        readonly property string fa_sun_o                   : "\uf185"
        readonly property string fa_superscript             : "\uf12b"
        readonly property string fa_support                 : "\uf1cd"
        readonly property string fa_table                   : "\uf0ce"
        readonly property string fa_tablet                  : "\uf10a"
        readonly property string fa_tachometer              : "\uf0e4"
        readonly property string fa_tag                     : "\uf02b"
        readonly property string fa_tags                    : "\uf02c"
        readonly property string fa_tasks                   : "\uf0ae"
        readonly property string fa_taxi                    : "\uf1ba"
        readonly property string fa_tencent_weibo           : "\uf1d5"
        readonly property string fa_terminal                : "\uf120"
        readonly property string fa_text_height             : "\uf034"
        readonly property string fa_text_width              : "\uf035"
        readonly property string fa_th                      : "\uf00a"
        readonly property string fa_th_large                : "\uf009"
        readonly property string fa_th_list                 : "\uf00b"
        readonly property string fa_thumb_tack              : "\uf08d"
        readonly property string fa_thumbs_down             : "\uf165"
        readonly property string fa_thumbs_o_down           : "\uf088"
        readonly property string fa_thumbs_o_up             : "\uf087"
        readonly property string fa_thumbs_up               : "\uf164"
        readonly property string fa_ticket                  : "\uf145"
        readonly property string fa_times                   : "\uf00d"
        readonly property string fa_times_circle            : "\uf057"
        readonly property string fa_times_circle_o          : "\uf05c"
        readonly property string fa_tint                    : "\uf043"
        readonly property string fa_toggle_down             : "\uf150"
        readonly property string fa_toggle_left             : "\uf191"
        readonly property string fa_toggle_off              : "\uf204"
        readonly property string fa_toggle_on               : "\uf205"
        readonly property string fa_toggle_right            : "\uf152"
        readonly property string fa_toggle_up               : "\uf151"
        readonly property string fa_trash                   : "\uf1f8"
        readonly property string fa_trash_o                 : "\uf014"
        readonly property string fa_tree                    : "\uf1bb"
        readonly property string fa_trello                  : "\uf181"
        readonly property string fa_trophy                  : "\uf091"
        readonly property string fa_truck                   : "\uf0d1"
        readonly property string fa_try                     : "\uf195"
        readonly property string fa_tty                     : "\uf1e4"
        readonly property string fa_tumblr                  : "\uf173"
        readonly property string fa_tumblr_square           : "\uf174"
        readonly property string fa_turkish_lira            : "\uf195"
        readonly property string fa_twitch                  : "\uf1e8"
        readonly property string fa_twitter                 : "\uf099"
        readonly property string fa_twitter_square          : "\uf081"
        readonly property string fa_umbrella                : "\uf0e9"
        readonly property string fa_underline               : "\uf0cd"
        readonly property string fa_undo                    : "\uf0e2"
        readonly property string fa_university              : "\uf19c"
        readonly property string fa_unlink                  : "\uf127"
        readonly property string fa_unlock                  : "\uf09c"
        readonly property string fa_unlock_alt              : "\uf13e"
        readonly property string fa_unsorted                : "\uf0dc"
        readonly property string fa_upload                  : "\uf093"
        readonly property string fa_usd                     : "\uf155"
        readonly property string fa_user                    : "\uf007"
        readonly property string fa_user_md                 : "\uf0f0"
        readonly property string fa_users                   : "\uf0c0"
        readonly property string fa_video_camera            : "\uf03d"
        readonly property string fa_vimeo_square            : "\uf194"
        readonly property string fa_vine                    : "\uf1ca"
        readonly property string fa_vk                      : "\uf189"
        readonly property string fa_volume_down             : "\uf027"
        readonly property string fa_volume_off              : "\uf026"
        readonly property string fa_volume_up               : "\uf028"
        readonly property string fa_warning                 : "\uf071"
        readonly property string fa_wechat                  : "\uf1d7"
        readonly property string fa_weibo                   : "\uf18a"
        readonly property string fa_weixin                  : "\uf1d7"
        readonly property string fa_wheelchair              : "\uf193"
        readonly property string fa_wifi                    : "\uf1eb"
        readonly property string fa_windows                 : "\uf17a"
        readonly property string fa_won                     : "\uf159"
        readonly property string fa_wordpress               : "\uf19a"
        readonly property string fa_wrench                  : "\uf0ad"
        readonly property string fa_xing                    : "\uf168"
        readonly property string fa_xing_square             : "\uf169"
        readonly property string fa_yahoo                   : "\uf19e"
        readonly property string fa_yelp                    : "\uf1e9"
        readonly property string fa_yen                     : "\uf157"
        readonly property string fa_youtube                 : "\uf167"
        readonly property string fa_youtube_play            : "\uf16a"
        readonly property string fa_youtube_square          : "\uf166"
    }


    /********************* LOCATIONS *******************************/
    QtObject {
        id: paths

        readonly property url assets: "../../assets/"
        readonly property url images: assets + "images/"
        readonly property url fonts: assets + "fonts/"
        readonly property url sounds: assets + "sounds/"
        readonly property url music: assets + "music/"
        readonly property url levels: assets + "levels/"
    }

    /**************** FUNCTIONS *******************************/
    function degreesToRadians(degrees) {
        return degrees * Math.PI / 180;
    }

    function radiansToDegrees(radians) {
        return radians * 180 / Math.PI;
    }

    function saveState() {

    }

    function toTimeString(timeInSeconds) {
        var minutes = Math.floor(timeInSeconds / 60)
        minutes = minutes < 10 ? ("0" + minutes) : minutes

        var seconds = timeInSeconds % 60
        seconds = seconds < 10 ? ("0" + seconds) : seconds

        return minutes + ":" + seconds
    }

    /********** END FUNCTIONS **************************************/
}

