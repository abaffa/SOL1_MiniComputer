object fmain: Tfmain
  Left = 228
  Top = 132
  Width = 1052
  Height = 850
  Caption = 'Microcode Builder 1.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  Scaled = False
  Visible = True
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 62
    Width = 873
    Height = 723
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl2: TPageControl
      Left = 0
      Top = 0
      Width = 873
      Height = 723
      ActivePage = TabSheet1
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MultiLine = True
      ParentFont = False
      TabIndex = 2
      TabOrder = 0
      object TabSheet2: TTabSheet
        Caption = 'Program data'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        object Splitter1: TSplitter
          Left = 553
          Top = 0
          Width = 6
          Height = 695
          Cursor = crHSplit
          AutoSnap = False
          Color = clCream
          ParentColor = False
          ResizeStyle = rsUpdate
        end
        object Panel2: TPanel
          Left = 161
          Top = 0
          Width = 392
          Height = 695
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object Panel8: TPanel
            Left = 361
            Top = 0
            Width = 31
            Height = 695
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 0
            object list_cycle: TListBox
              Left = 0
              Top = 0
              Width = 31
              Height = 695
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              BiDiMode = bdLeftToRight
              BorderStyle = bsNone
              Color = clBtnFace
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'Consolas'
              Font.Style = [fsBold]
              ItemHeight = 13
              Items.Strings = (
                ' 00'
                ' 01'
                ' 02'
                ' 03'
                ' 04'
                ' 05'
                ' 06'
                ' 07'
                ' 08'
                ' 09'
                ' 0A'
                ' 0B'
                ' 0C'
                ' 0D'
                ' 0E'
                ' 0F'
                ' 10'
                ' 11'
                ' 12'
                ' 13'
                ' 14'
                ' 15'
                ' 16'
                ' 17'
                ' 18'
                ' 19'
                ' 1A'
                ' 1B'
                ' 1C'
                ' 1D'
                ' 1E'
                ' 1F'
                ' 20'
                ' 21'
                ' 22'
                ' 23'
                ' 24'
                ' 25'
                ' 26'
                ' 27'
                ' 28'
                ' 29'
                ' 2A'
                ' 2B'
                ' 2C'
                ' 2D'
                ' 2E'
                ' 2F'
                ' 30'
                ' 31'
                ' 32'
                ' 33'
                ' 34'
                ' 35'
                ' 36'
                ' 37'
                ' 38'
                ' 39'
                ' 3A'
                ' 3B'
                ' 3C'
                ' 3D'
                ' 3E'
                ' 3F')
              MultiSelect = True
              ParentBiDiMode = False
              ParentFont = False
              PopupMenu = PopupMenu1
              TabOrder = 0
              OnClick = list_cycleClick
              OnKeyPress = list_cycleKeyPress
            end
          end
          object Panel9: TPanel
            Left = 0
            Top = 0
            Width = 361
            Height = 695
            Align = alClient
            TabOrder = 1
            object Splitter2: TSplitter
              Left = 1
              Top = 394
              Width = 359
              Height = 4
              Cursor = crVSplit
              Align = alBottom
              AutoSnap = False
              Color = clBtnHighlight
              ParentColor = False
              ResizeStyle = rsUpdate
            end
            object control_list: TCheckListBox
              Left = 1
              Top = 1
              Width = 359
              Height = 393
              Cursor = crArrow
              OnClickCheck = control_listClickCheck
              Align = alClient
              Color = clWhite
              Columns = 3
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              Items.Strings = (
                'next_0'
                'next_1'
                'offset_0'
                'offset_1'
                'offset_2'
                'offset_3'
                'offset_4'
                'offset_5'
                'offset_6'
                'cond_inv'
                'cond_flags_src'
                'cond_sel_0'
                'cond_sel_1'
                'cond_sel_2'
                'cond_sel_3'
                'ESCAPE'
                'uzf_in_src_0'
                'uzf_in_src_1'
                'ucf_in_src_0'
                'ucf_in_src_1'
                'usf_in_src'
                'uof_in_src'
                'IR_wrt'
                'status_wrt'
                'shift_src_0'
                'shift_src_1'
                'shift_src_2'
                'zbus_out_src_0'
                'zbus_out_src_1'
                'alu_a_src_0'
                'alu_a_src_1'
                'alu_a_src_2'
                'alu_a_src_3'
                'alu_a_src_4'
                'alu_a_src_5'
                'alu_op_0'
                'alu_op_1'
                'alu_op_2'
                'alu_op_3'
                'alu_mode'
                'alu_cf_in_src_0'
                'alu_cf_in_src_1'
                'alu_cf_in_inv'
                'zf_in_src_0'
                'zf_in_src_1'
                'alu_cf_out_inv'
                'cf_in_src_0'
                'cf_in_src_1'
                'cf_in_src_2'
                'sf_in_src_0'
                'sf_in_src_1'
                'of_in_src_0'
                'of_in_src_1'
                'of_in_src_2'
                'rd'
                'wr'
                'alu_b_src_0'
                'alu_b_src_1'
                'alu_b_src_2'
                'display_reg_load'
                'dl_wrt'
                'dh_wrt'
                'cl_wrt'
                'ch_wrt'
                'bl_wrt'
                'bh_wrt'
                'al_wrt'
                'ah_wrt'
                'mdr_in_src'
                'mdr_out_src'
                'mdr_out_en'
                'mdrl_wrt'
                'mdrh_wrt'
                'tdrl_wrt'
                'tdrh_wrt'
                'dil_wrt'
                'dih_wrt'
                'sil_wrt'
                'sih_wrt'
                'marl_wrt'
                'marh_wrt'
                'bpl_wrt'
                'bph_wrt'
                'pcl_wrt'
                'pch_wrt'
                'spl_wrt'
                'sph_wrt'
                'unused'
                'unused'
                'int_vector_wrt'
                'mask_flags_wrt'
                'mar_in_src'
                'int_ack'
                'clear_all_ints'
                'ptb_wrt'
                'pagtbl_ram_we'
                'mdr_to_pagtbl_en'
                'force_user_ptb'
                'unused'
                'unused'
                'unused'
                'unused'
                'gl_wrt'
                'gh_wrt'
                'imm_0'
                'imm_1'
                'imm_2'
                'imm_3'
                'imm_4'
                'imm_5'
                'imm_6'
                'imm_7'
                'unused'
                'unused'
                'unused'
                'unused'
                'unused'
                'unused'
                'unused'
                'unused')
              ParentFont = False
              PopupMenu = PopupMenu2
              TabOrder = 0
            end
            object Panel3: TPanel
              Left = 1
              Top = 398
              Width = 359
              Height = 296
              Align = alBottom
              BevelOuter = bvNone
              TabOrder = 1
              object memo_info: TMemo
                Left = 0
                Top = 25
                Width = 359
                Height = 271
                Align = alClient
                Color = clWhite
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clNavy
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                MaxLength = 256
                ParentFont = False
                ScrollBars = ssVertical
                TabOrder = 0
                WantTabs = True
                OnKeyDown = memo_infoKeyDown
                OnKeyUp = memo_infoKeyUp
              end
              object memo_name: TMemo
                Left = 0
                Top = 0
                Width = 359
                Height = 25
                Align = alTop
                Color = clBtnFace
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clNavy
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                TabOrder = 1
                WantReturns = False
                OnChange = memo_nameChange
              end
            end
          end
        end
        object Panel4: TPanel
          Left = 559
          Top = 0
          Width = 306
          Height = 695
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object list_names: TListBox
            Left = 0
            Top = 0
            Width = 306
            Height = 695
            AutoComplete = False
            Align = alClient
            BevelInner = bvNone
            Color = clWhite
            Columns = 4
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -11
            Font.Name = 'Consolas'
            Font.Style = []
            ItemHeight = 13
            ParentFont = False
            TabOrder = 0
            OnClick = list_namesClick
          end
        end
        object Panel10: TPanel
          Left = 0
          Top = 0
          Width = 161
          Height = 695
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 2
          object GroupBox2: TGroupBox
            Left = 0
            Top = 0
            Width = 161
            Height = 125
            Align = alTop
            Caption = 'Next Micro-Instruction'
            Color = clBtnFace
            Ctl3D = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
            object combo_type: TComboBox
              Left = 8
              Top = 22
              Width = 145
              Height = 21
              BevelInner = bvNone
              BevelOuter = bvNone
              Style = csDropDownList
              Ctl3D = True
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
              Text = 'Next by Offset'
              OnSelect = combo_typeSelect
              Items.Strings = (
                'Next by Offset'
                'Branch'
                'Next is Fetch'
                'Next by IR')
            end
            object combo_cond: TComboBox
              Left = 8
              Top = 46
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'zf'
              OnSelect = combo_condSelect
              Items.Strings = (
                'zf'
                'cf / LU'
                'sf'
                'of'
                'L'
                'LE'
                'LEU'
                'DMA_REQ'
                'STATUS_MODE'
                'WAIT'
                'INT_PENDING'
                'EXT_INPUT'
                'STATUS_DIR'
                'DISPLAY_LOAD'
                'unused'
                'unused'
                '~zf'
                '~cf / GEU'
                '~sf'
                '~of'
                'GE'
                'G'
                'GU'
                '~DMA_REQ'
                '~STATUS_MODE'
                '~WAIT'
                '~INT_PENDING'
                '~EXT_INPUT'
                '~STATUS_DIR'
                '~DISPLAY_R_LOAD'
                'unused'
                'unused')
            end
            object combo_flags_src: TComboBox
              Left = 8
              Top = 70
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 2
              Text = 'CPU Flags'
              OnSelect = combo_flags_srcSelect
              Items.Strings = (
                'CPU Flags'
                'Microcode Flags')
            end
            object edt_integer: TEdit
              Left = 8
              Top = 94
              Width = 46
              Height = 21
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              TabOrder = 3
              Text = '1'
            end
            object Button19: TButton
              Left = 57
              Top = 94
              Width = 45
              Height = 21
              Caption = 'Offset'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              TabOrder = 4
              OnClick = Button19Click
            end
            object Button20: TButton
              Left = 103
              Top = 94
              Width = 48
              Height = 21
              Caption = 'Imm'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              TabOrder = 5
              OnClick = Button20Click
            end
          end
          object GroupBox1: TGroupBox
            Left = 0
            Top = 417
            Width = 161
            Height = 48
            Align = alTop
            Caption = 'ALU to ZBus'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
            object combo_zbus: TComboBox
              Left = 8
              Top = 18
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'Normal ALU Result'
              OnSelect = combo_zbusSelect
              Items.Strings = (
                'Normal ALU Result'
                'Shifted Right'
                'Shifted Left'
                'Sign Extend')
            end
          end
          object GroupBox3: TGroupBox
            Left = 0
            Top = 634
            Width = 161
            Height = 121
            Align = alTop
            Caption = 'Arithmetic Flags In'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
            object combo_of_in: TComboBox
              Left = 8
              Top = 90
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'unchanged'
              OnSelect = combo_of_inSelect
              Items.Strings = (
                'unchanged'
                'ALU_OF'
                'ZBUS_7'
                'ZBUS_3'
                '(U_SF) XOR (ZBUS_7)')
            end
            object combo_sf_in: TComboBox
              Left = 8
              Top = 66
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'unchanged'
              OnSelect = combo_sf_inSelect
              Items.Strings = (
                'unchanged'
                'ZBUS_7'
                'GND'
                'ZBUS_2')
            end
            object combo_cf_in: TComboBox
              Left = 8
              Top = 42
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 2
              Text = 'unchanged'
              OnSelect = combo_cf_inSelect
              Items.Strings = (
                'unchanged'
                'ALU Final CF'
                'ALU_OUTPUT_0'
                'ZBUS_1'
                'ALU_OUTPUT_7')
            end
            object combo_zf_in: TComboBox
              Left = 8
              Top = 18
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 3
              Text = 'unchanged'
              OnSelect = combo_zf_inSelect
              Items.Strings = (
                'unchanged'
                'ALU_ZF'
                'ALU_ZF && ZF'
                'ZBUS_0')
            end
          end
          object GroupBox4: TGroupBox
            Left = 0
            Top = 245
            Width = 161
            Height = 72
            Align = alTop
            Caption = 'ALU Inputs A/B'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 3
            object combo_aluAmux: TComboBox
              Left = 8
              Top = 19
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = '0x00: al'
              OnSelect = combo_aluAmuxSelect
              Items.Strings = (
                '0x00: al'
                '0x01: ah'
                '0x02: bl'
                '0x03: bh'
                '0x04: cl'
                '0x05: ch'
                '0x06: dl'
                '0x07: dh'
                '0x08: sp_l'
                '0x09: sp_h'
                '0x0A: bp_l'
                '0x0B: bp_h'
                '0x0C: si_l'
                '0x0D: si_h'
                '0x0E: di_l'
                '0x0F: di_h'
                '0x10: pc_l'
                '0x11: pc_h'
                '0x12: mar_l'
                '0x13: mar_h'
                '0x14: mdr_l'
                '0x15: mdr_h'
                '0x16: tdr_l'
                '0x17: tdr_h'
                '0x18: ksp_l'
                '0x19: ksp_h'
                '0x1A: int_vector'
                '0x1B: int_masks'
                '0x1C: int_status'
                '0x1D:'
                '0x1E:'
                '0x1F: '
                '0x20: arithmetic_flags'
                '0x21: status_flags'
                '0x22: gl'
                '0x23: gh')
            end
            object combo_aluBmux: TComboBox
              Left = 8
              Top = 42
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'immediate'
              OnSelect = combo_aluBmuxSelect
              Items.Strings = (
                'immediate'
                ''
                ''
                ''
                'mdr_l'
                'mdr_h'
                'tdr_l'
                'tdr_h')
            end
          end
          object GroupBox5: TGroupBox
            Left = 0
            Top = 171
            Width = 161
            Height = 74
            Align = alTop
            Caption = 'MDR In/Out Src'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
            object combo_mdr_src_out: TComboBox
              Left = 8
              Top = 44
              Width = 145
              Height = 21
              Style = csDropDownList
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'MDR Low'
              OnSelect = combo_mdr_src_outSelect
              Items.Strings = (
                'MDR Low'
                'MDR High')
            end
            object combo_mdr_src: TComboBox
              Left = 8
              Top = 20
              Width = 145
              Height = 21
              Style = csDropDownList
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'ZBus'
              OnSelect = combo_mdr_srcSelect
              Items.Strings = (
                'ZBus'
                'DataBus')
            end
          end
          object GroupBox6: TGroupBox
            Left = 0
            Top = 515
            Width = 161
            Height = 119
            Align = alTop
            Caption = 'Micro Flags In'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
            object combo_uof: TComboBox
              Left = 8
              Top = 89
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'unchanged'
              OnSelect = combo_uofSelect
              Items.Strings = (
                'unchanged'
                'ALU_OF')
            end
            object combo_usf: TComboBox
              Left = 8
              Top = 65
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'unchanged'
              OnSelect = combo_usfSelect
              Items.Strings = (
                'unchanged'
                'ZBUS_7')
            end
            object combo_ucf: TComboBox
              Left = 8
              Top = 41
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 2
              Text = 'unchanged'
              OnSelect = combo_ucfSelect
              Items.Strings = (
                'unchanged'
                'ALU Final CF'
                'ALU_OUTPUT_0'
                'ALU_OUTPUT_7')
            end
            object combo_uzf: TComboBox
              Left = 8
              Top = 17
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 3
              Text = 'unchanged'
              OnSelect = combo_uzfSelect
              Items.Strings = (
                'unchanged'
                'ALU_ZF'
                'ALU_ZF && uZF'
                'gnd')
            end
          end
          object GroupBox7: TGroupBox
            Left = 0
            Top = 317
            Width = 161
            Height = 100
            Align = alTop
            Caption = 'ALU Operation / Carry In'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 6
            object combo_aluop: TComboBox
              Left = 8
              Top = 20
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'ALU Operation'
              OnSelect = combo_aluopSelect
              Items.Strings = (
                'ALU Operation'
                ''
                'plus'
                'minus'
                'and'
                'or'
                'xor'
                'A'
                'B'
                'not A'
                'not B'
                'nand'
                'nor'
                'nxor')
            end
            object combo_alu_cf_in: TComboBox
              Left = 8
              Top = 44
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 1
              Text = 'vcc'
              OnSelect = combo_alu_cf_inSelect
              Items.Strings = (
                'vcc'
                'cf'
                'u_cf'
                ''
                'gnd'
                '~cf'
                '~u_cf'
                '')
            end
            object combo_alu_cf_out_inv: TComboBox
              Left = 8
              Top = 68
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 50
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 2
              Text = 'Carry-out not inverted'
              OnSelect = combo_alu_cf_out_invSelect
              Items.Strings = (
                'Carry-out not inverted'
                'Carry-out inverted')
            end
          end
          object GroupBox8: TGroupBox
            Left = 0
            Top = 125
            Width = 161
            Height = 46
            Align = alTop
            Caption = 'MAR In Src'
            TabOrder = 7
            object combo_mar_src: TComboBox
              Left = 8
              Top = 18
              Width = 145
              Height = 21
              Style = csDropDownList
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'MAR IN : ZBus'
              OnSelect = combo_mar_srcSelect
              Items.Strings = (
                'MAR IN : ZBus'
                'MAR IN : PC')
            end
          end
          object GroupBox9: TGroupBox
            Left = 0
            Top = 465
            Width = 161
            Height = 50
            Align = alTop
            Caption = 'Shift Src'
            TabOrder = 8
            object combo_shift_src: TComboBox
              Left = 8
              Top = 19
              Width = 145
              Height = 21
              Style = csDropDownList
              DropDownCount = 20
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ItemHeight = 13
              ItemIndex = 0
              ParentFont = False
              TabOrder = 0
              Text = 'gnd'
              OnSelect = combo_shift_srcSelect
              Items.Strings = (
                'gnd'
                'uCF'
                'CF'
                'ALU Result [0]'
                'ALU Result [7]')
            end
          end
        end
      end
      object TabSheet9: TTabSheet
        Caption = 'Instruction List'
        ImageIndex = 4
        object ListBox2: TListBox
          Left = 0
          Top = 0
          Width = 865
          Height = 695
          AutoComplete = False
          Align = alClient
          BevelInner = bvNone
          Color = clWhite
          Columns = 4
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Consolas'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          PopupMenu = PopupMenu4
          Sorted = True
          TabOrder = 0
        end
      end
      object TabSheet1: TTabSheet
        Caption = 'Web / COM'
        ImageIndex = 5
        object Panel23: TPanel
          Left = 0
          Top = 0
          Width = 865
          Height = 695
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object Splitter3: TSplitter
            Left = 553
            Top = 97
            Width = 8
            Height = 537
            Cursor = crHSplit
            AutoSnap = False
            ResizeStyle = rsUpdate
          end
          object Panel27: TPanel
            Left = 0
            Top = 0
            Width = 865
            Height = 97
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Button11: TButton
              Left = 184
              Top = 26
              Width = 75
              Height = 25
              Caption = 'Open Port'
              TabOrder = 0
              OnClick = Button11Click
            end
            object edtbaud: TLabeledEdit
              Left = 96
              Top = 24
              Width = 73
              Height = 21
              EditLabel.Width = 54
              EditLabel.Height = 13
              EditLabel.Caption = 'Baud Rate:'
              EditLabel.Font.Charset = DEFAULT_CHARSET
              EditLabel.Font.Color = clBlack
              EditLabel.Font.Height = -11
              EditLabel.Font.Name = 'MS Sans Serif'
              EditLabel.Font.Style = []
              EditLabel.ParentFont = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              LabelPosition = lpAbove
              LabelSpacing = 3
              ParentFont = False
              TabOrder = 1
              Text = '38400'
            end
            object edtport: TLabeledEdit
              Left = 16
              Top = 24
              Width = 73
              Height = 21
              Ctl3D = True
              EditLabel.Width = 62
              EditLabel.Height = 13
              EditLabel.Caption = 'Port Number:'
              EditLabel.Font.Charset = DEFAULT_CHARSET
              EditLabel.Font.Color = clBlack
              EditLabel.Font.Height = -11
              EditLabel.Font.Name = 'MS Sans Serif'
              EditLabel.Font.Style = []
              EditLabel.ParentFont = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              LabelPosition = lpAbove
              LabelSpacing = 3
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 2
              Text = 'COM6'
            end
            object edtdatabits: TLabeledEdit
              Left = 16
              Top = 64
              Width = 73
              Height = 21
              EditLabel.Width = 46
              EditLabel.Height = 13
              EditLabel.Caption = 'Data Bits:'
              EditLabel.Font.Charset = DEFAULT_CHARSET
              EditLabel.Font.Color = clBlack
              EditLabel.Font.Height = -11
              EditLabel.Font.Name = 'MS Sans Serif'
              EditLabel.Font.Style = []
              EditLabel.ParentFont = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              LabelPosition = lpAbove
              LabelSpacing = 3
              ParentFont = False
              TabOrder = 3
              Text = '8'
            end
            object edtstopbits: TLabeledEdit
              Left = 96
              Top = 64
              Width = 73
              Height = 21
              EditLabel.Width = 45
              EditLabel.Height = 13
              EditLabel.Caption = 'Stop Bits:'
              EditLabel.Font.Charset = DEFAULT_CHARSET
              EditLabel.Font.Color = clBlack
              EditLabel.Font.Height = -11
              EditLabel.Font.Name = 'MS Sans Serif'
              EditLabel.Font.Style = []
              EditLabel.ParentFont = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clNavy
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              LabelPosition = lpAbove
              LabelSpacing = 3
              ParentFont = False
              TabOrder = 4
              Text = '1'
            end
            object Button10: TButton
              Left = 264
              Top = 26
              Width = 75
              Height = 25
              Caption = 'Close Port'
              TabOrder = 5
              OnClick = Button10Click
            end
            object Button26: TButton
              Left = 184
              Top = 58
              Width = 155
              Height = 25
              Caption = 'Clear Terminal'
              TabOrder = 6
              OnClick = Button26Click
            end
            object Button16: TButton
              Left = 343
              Top = 26
              Width = 106
              Height = 25
              Caption = 'Clear HTML'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              TabOrder = 7
              OnClick = Button16Click
            end
            object Button8: TButton
              Left = 344
              Top = 58
              Width = 105
              Height = 25
              Caption = 'Turn Server OFF'
              TabOrder = 8
              OnClick = Button8Click
            end
            object edt_timeout: TLabeledEdit
              Left = 464
              Top = 24
              Width = 73
              Height = 21
              EditLabel.Width = 41
              EditLabel.Height = 13
              EditLabel.Caption = 'Timeout:'
              LabelPosition = lpAbove
              LabelSpacing = 3
              TabOrder = 9
              Text = '5'
            end
            object edt_chars: TLabeledEdit
              Left = 464
              Top = 64
              Width = 73
              Height = 21
              EditLabel.Width = 30
              EditLabel.Height = 13
              EditLabel.Caption = 'Chars:'
              LabelPosition = lpAbove
              LabelSpacing = 3
              TabOrder = 10
              Text = '512'
            end
            object Button2: TButton
              Left = 576
              Top = 24
              Width = 97
              Height = 25
              Caption = 'Open Telnet'
              TabOrder = 11
              OnClick = Button2Click
            end
            object Button9: TButton
              Left = 576
              Top = 56
              Width = 97
              Height = 25
              Caption = 'Close Telnet'
              TabOrder = 12
              OnClick = Button9Click
            end
          end
          object memo_com_out: TMemo
            Left = 0
            Top = 97
            Width = 553
            Height = 537
            Align = alLeft
            Color = clWhite
            Ctl3D = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            HideSelection = False
            ParentCtl3D = False
            ParentFont = False
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 1
            WantReturns = False
          end
          object m_com_in: TMemo
            Left = 0
            Top = 634
            Width = 865
            Height = 61
            Align = alBottom
            Ctl3D = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clNavy
            Font.Height = -11
            Font.Name = 'Courier New'
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 2
            WantReturns = False
            OnKeyDown = m_com_inKeyDown
          end
          object memo_textarea: TMemo
            Left = 561
            Top = 97
            Width = 304
            Height = 537
            Align = alClient
            ScrollBars = ssVertical
            TabOrder = 3
          end
        end
      end
    end
  end
  object Panel15: TPanel
    Left = 873
    Top = 62
    Width = 171
    Height = 723
    Align = alRight
    TabOrder = 1
    Visible = False
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 169
      Height = 721
      Align = alClient
      BorderStyle = bsNone
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      Lines.Strings = (
        'D   O    H    ASCII'
        '0   0    0    NUL'
        '1   1    1    SOH'
        '2   2    2    STX'
        '3   3    3    ETX'
        '4   4    4    EOT'
        '5   5    5    ENQ'
        '6   6    6    ACK'
        '7   7    7    BEL'
        '8   10   8    BS'
        '9   11   9    HT'
        '10  12   A    LF'
        '11  13   B    VT'
        '12  14   C    FF'
        '13  15   D    CR'
        '14  16   E    SO'
        '15  17   F    SI'
        '16  20   10   DLE'
        '17  21   11   DC1'
        '18  22   12   DC2'
        '19  23   13   DC3'
        '20  24   14   DC4'
        '21  25   15   NAK'
        '22  26   16   SYN'
        '23  27   17   ETB'
        '24  30   18   CAN'
        '25  31   19   EM'
        '26  32   1A   SUB'
        '27  33   1B   ESC'
        '28  34   1C   FS'
        '29  35   1D   GS'
        '30  36   1E   RS'
        '31  37   1F   US'
        '32  40   20   SP'
        '33  41   21   !'
        '34  42   22   "'
        '35  43   23   #'
        '36  44   24   $'
        '37  45   25   %'
        '38  46   26   &'
        '39  47   27   '#39
        '40  50   28   ('
        '41  51   29   )'
        '42  52   2A   *'
        '43  53   2B   +'
        '44  54   2C   '#180
        '45  55   2D   -'
        '46  56   2E   .'
        '47  57   2F   /'
        '48  60   30   0'
        '49  61   31   1'
        '50  62   32   2'
        '51  63   33   3'
        '52  64   34   4'
        '53  65   35   5'
        '54  67   36   6'
        '55  70   37   7'
        '56  71   38   8'
        '57  72   39   9'
        '58  73   3A   :'
        '59  74   3B   ;'
        '60  75   3C   <'
        '61  76   3D   ='
        '62  77   3E   >'
        '63  80   3F   ?'
        '64  81   40   @'
        '65  82   41   A'
        '66  83   42   B'
        '67  84   43   C'
        '68  85   44   D'
        '69  86   45   E'
        '70  87   46   F'
        '71  90   47   G'
        '72  91   48   H'
        '73  92   49   I'
        '74  93   4A   J'
        '75  94   4B   K'
        '76  95   4C   L'
        '77  96   4D   M'
        '78  97   4E   N'
        '79  100  4F   O'
        '80  101  50   P'
        '81  102  51   Q'
        '82  103  52   R'
        '83  104  53   S'
        '84  105  54   T'
        '85  106  55   U'
        '86  107  56   V'
        '87  110  57   W'
        '88  111  58   X'
        '89  112  59   Y'
        '90  113  5A   Z'
        '91  114  5B   ['
        '92  115  5C   \'
        '93  116  5D   ]'
        '94  117  5E   ^'
        '95  120  5F   _'
        '96  121  60   `'
        '97  122  61   a'
        '98  123  62   b'
        '99  124  63   c'
        '100 125  64   d'
        '101 126  65   e'
        '102 127  66   f'
        '103 130  67   g'
        '104 131  68   h'
        '105 132  69   i'
        '106 133  6A   j'
        '107 134  6B   k'
        '108 135  6C   l'
        '109 136  6D   m'
        '110 137  6E   n'
        '111 140  6F   o'
        '112 141  70   p'
        '113 142  71   q'
        '114 143  72   r'
        '115 144  73   s'
        '116 145  74   t'
        '117 146  75   u'
        '118 147  76   v'
        '119 150  77   w'
        '120 151  78   x'
        '121 152  79   y'
        '122 153  7A   z'
        '123 154  7B   {'
        '124 155  7C   |'
        '125 156  7D   }'
        '126 157  7E   ~')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 1044
    Height = 62
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 2
    object SpeedButton7: TSpeedButton
      Left = 402
      Top = 7
      Width = 76
      Height = 21
      Caption = 'Quit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButton7Click
    end
    object Button1: TButton
      Left = 729
      Top = 34
      Width = 80
      Height = 21
      Caption = 'Notepad'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button17: TButton
      Left = 649
      Top = 34
      Width = 80
      Height = 21
      Caption = 'Calculator'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = Button17Click
    end
    object Button14: TButton
      Left = 569
      Top = 34
      Width = 80
      Height = 21
      Caption = 'ASCII'
      TabOrder = 2
    end
    object Button18: TButton
      Left = 489
      Top = 34
      Width = 80
      Height = 21
      Caption = 'Command'
      TabOrder = 3
      OnClick = Button18Click
    end
    object Button15: TButton
      Left = 409
      Top = 34
      Width = 80
      Height = 21
      Caption = 'Programmer'
      TabOrder = 4
      OnClick = Button15Click
    end
    object BitBtn2: TBitBtn
      Left = 156
      Top = 34
      Width = 60
      Height = 21
      Caption = '>>>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = BitBtn2Click
    end
    object Button32: TButton
      Left = 329
      Top = 34
      Width = 80
      Height = 21
      Caption = 'Hex'
      TabOrder = 6
      OnClick = Button32Click
    end
    object Button4: TButton
      Left = 111
      Top = 34
      Width = 45
      Height = 21
      Caption = '>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      OnClick = Button4Click
    end
    object Button3: TButton
      Left = 66
      Top = 34
      Width = 45
      Height = 21
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = Button3Click
    end
    object Button30: TButton
      Left = 223
      Top = 34
      Width = 106
      Height = 21
      Caption = 'Working Directory'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
      OnClick = Button30Click
    end
    object BitBtn1: TBitBtn
      Left = 6
      Top = 34
      Width = 60
      Height = 21
      Caption = '<<<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 10
      OnClick = BitBtn1Click
    end
    object Button13: TButton
      Left = 231
      Top = 7
      Width = 75
      Height = 21
      Caption = 'Shift Right'
      TabOrder = 11
      OnClick = Button13Click
    end
    object Button12: TButton
      Left = 156
      Top = 7
      Width = 75
      Height = 21
      Caption = 'Shift Left'
      TabOrder = 12
      OnClick = Button12Click
    end
    object Button7: TButton
      Left = 316
      Top = 7
      Width = 75
      Height = 21
      Caption = 'Reset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 13
      OnClick = Button7Click
    end
    object Button6: TButton
      Left = 81
      Top = 7
      Width = 75
      Height = 21
      Caption = 'Paste'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 14
      OnClick = Button6Click
    end
    object Button5: TButton
      Left = 6
      Top = 7
      Width = 75
      Height = 21
      Caption = 'Copy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 15
      OnClick = Button5Click
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 785
    Width = 1044
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Microcode Files (*.*)|*.*'
    Left = 728
    Top = 344
  end
  object SaveDialog2: TSaveDialog
    Filter = 'Microcode Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save As'
    Left = 760
    Top = 344
  end
  object PopupMenu1: TPopupMenu
    Left = 608
    Top = 344
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object Insert1: TMenuItem
      Caption = 'Insert'
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object ShiftLeft1: TMenuItem
      Caption = 'Shift Left'
      object N12: TMenuItem
        Caption = '1'
      end
      object N22: TMenuItem
        Caption = '2'
      end
      object N32: TMenuItem
        Caption = '3'
      end
      object N42: TMenuItem
        Caption = '4'
      end
      object N52: TMenuItem
        Caption = '5'
      end
      object N102: TMenuItem
        Caption = '10'
      end
    end
    object Shift1: TMenuItem
      Caption = 'Shift Right'
      object N11: TMenuItem
        Caption = '1'
        OnClick = N11Click
      end
      object N21: TMenuItem
        Caption = '2'
        OnClick = N21Click
      end
      object N31: TMenuItem
        Caption = '3'
        OnClick = N31Click
      end
      object N41: TMenuItem
        Caption = '4'
        OnClick = N41Click
      end
      object N51: TMenuItem
        Caption = '5'
        OnClick = N51Click
      end
      object N101: TMenuItem
        Caption = '10'
        OnClick = N101Click
      end
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object Reset1: TMenuItem
      Caption = 'Reset'
      OnClick = Reset1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 640
    Top = 344
    object microcodetype1: TMenuItem
      Caption = 'Microcode Type'
      object offset1: TMenuItem
        Caption = 'offset'
      end
      object branch1: TMenuItem
        Caption = 'branch'
      end
      object prefetch1: TMenuItem
        Caption = 'pre-fetch'
      end
      object postfetch1: TMenuItem
        Caption = 'post-fetch'
      end
    end
    object conditioncode1: TMenuItem
      Caption = 'Condition Code'
      object TMenuItem
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object MDRSource1: TMenuItem
      Caption = 'MDR Source (In)'
      object ZBus1: TMenuItem
        Caption = 'Z Bus'
      end
      object DataBus1: TMenuItem
        Caption = 'External Data Bus'
      end
    end
    object MDRSourceOut1: TMenuItem
      Caption = 'MDR Source (Out)'
      object Low1: TMenuItem
        Caption = 'Low'
      end
      object High1: TMenuItem
        Caption = 'High'
      end
    end
    object MARSource1: TMenuItem
      Caption = 'MAR Source (In)'
      object ZBus2: TMenuItem
        Caption = 'Z Bus'
      end
      object PC1: TMenuItem
        Caption = 'PC'
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object ALUAInput1: TMenuItem
      Caption = 'ALU (A)'
      object al1: TMenuItem
        Caption = 'al'
      end
      object ah1: TMenuItem
        Caption = 'ah'
      end
      object bl1: TMenuItem
        Caption = 'bl'
      end
      object bh1: TMenuItem
        Caption = 'bh'
      end
      object cl1: TMenuItem
        Caption = 'cl'
      end
      object ch1: TMenuItem
        Caption = 'ch'
      end
    end
    object ALuB1: TMenuItem
      Caption = 'ALU (B)'
      object mdrl1: TMenuItem
        Caption = 'mdrl'
      end
      object mdrh1: TMenuItem
        Caption = 'mdrh'
      end
      object tdrl1: TMenuItem
        Caption = 'tdrl'
      end
      object tdrh1: TMenuItem
        Caption = 'tdrh'
      end
      object immediate1: TMenuItem
        Caption = 'immediate'
      end
    end
    object ALUOperation1: TMenuItem
      Caption = 'ALU Operation'
      object Addition1: TMenuItem
        Caption = 'Addition'
      end
      object Subtraction1: TMenuItem
        Caption = 'Subtraction'
      end
      object And1: TMenuItem
        Caption = 'And'
      end
      object Or1: TMenuItem
        Caption = 'Or'
      end
      object Xor1: TMenuItem
        Caption = 'Xor'
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object A1: TMenuItem
        Caption = 'A'
      end
      object B1: TMenuItem
        Caption = 'B'
      end
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object ALUCFInSrc1: TMenuItem
      Caption = 'ALU CF In Src'
      object vcc1: TMenuItem
        Caption = 'vcc'
      end
      object gnd1: TMenuItem
        Caption = 'gnd'
      end
      object CF1: TMenuItem
        Caption = 'CF'
      end
      object CF2: TMenuItem
        Caption = '~CF'
      end
      object UCF1: TMenuItem
        Caption = 'U_CF'
      end
      object UCF2: TMenuItem
        Caption = '~U_CF'
      end
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object ZFInSrc1: TMenuItem
      Caption = 'ZF In Src'
      object KeepZF1: TMenuItem
        Caption = 'Keep ZF'
      end
      object ALUZF1: TMenuItem
        Caption = 'ALU ZF'
      end
      object ALUZFZF1: TMenuItem
        Caption = 'ALU ZF && ZF'
      end
    end
  end
  object OpenDialog2: TOpenDialog
    Filter = 'All files (*.*)|*.*|Assembly (*.asm)|*.asm|Text (*.txt)|*.txt'
    Left = 696
    Top = 344
  end
  object PopupMenu3: TPopupMenu
    Left = 544
    Top = 344
    object Bookmark1: TMenuItem
      Caption = 'Create bookmark'
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Copy2: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
    end
    object Copy3: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      ShortCut = 16449
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object Find1: TMenuItem
      Caption = 'Find'
      ShortCut = 16454
      OnClick = Find1Click
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object Wordwrap1: TMenuItem
      Caption = 'Wordwrap'
      Checked = True
    end
    object N27: TMenuItem
      Caption = '-'
    end
    object Open4: TMenuItem
      Caption = 'Open'
    end
    object Save3: TMenuItem
      Caption = 'Save'
    end
    object SaveAs3: TMenuItem
      Caption = 'Save As'
    end
    object Assemble2: TMenuItem
      Caption = 'Assemble'
    end
  end
  object MainMenu1: TMainMenu
    Left = 544
    Top = 304
    object File1: TMenuItem
      Caption = 'Microcode File'
      object New1: TMenuItem
        Caption = 'New'
        ImageIndex = 0
        OnClick = New1Click
      end
      object N25: TMenuItem
        Caption = '-'
      end
      object OpenRecent1: TMenuItem
        Caption = 'Open Recent'
        ShortCut = 112
        OnClick = OpenRecent1Click
      end
      object Open1: TMenuItem
        Caption = 'Open'
        ShortCut = 113
        OnClick = Open1Click
      end
      object Save1: TMenuItem
        Caption = 'Save'
        ShortCut = 114
        OnClick = Save1Click
      end
      object SaveAs1: TMenuItem
        Caption = 'Save As'
        ShortCut = 115
        OnClick = SaveAs1Click
      end
    end
    object Microcodeedit1: TMenuItem
      Caption = 'Edit'
      object Copyinstruction1: TMenuItem
        Caption = 'Copy instruction'
        ShortCut = 16504
        OnClick = Copyinstruction1Click
      end
      object PasteInstruction1: TMenuItem
        Caption = 'Paste Instruction'
        ShortCut = 16505
        OnClick = PasteInstruction1Click
      end
    end
    object Settings1: TMenuItem
      Caption = 'Settings'
      object MicrocodeEditor2: TMenuItem
        Caption = 'Microcode editor'
        object ReadOnly1: TMenuItem
          Caption = 'Read-Only mode'
          Checked = True
          OnClick = ReadOnly1Click
        end
      end
      object Options2: TMenuItem
        Caption = 'Options'
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object Prompt1: TMenuItem
        Caption = 'Prompt'
        OnClick = Prompt1Click
      end
      object N26: TMenuItem
        Caption = '-'
      end
      object MicrocodeEditor1: TMenuItem
        Caption = 'Microcode Editor'
        OnClick = MicrocodeEditor1Click
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object ASCIITable1: TMenuItem
        Caption = 'ASCII Table'
        OnClick = ASCIITable1Click
      end
      object N14: TMenuItem
        Caption = '-'
      end
      object MicrocodeInstructioncolumns1: TMenuItem
        Caption = 'Microcode Instruction columns'
        object N110: TMenuItem
          Caption = '1'
          OnClick = N110Click
        end
        object N28: TMenuItem
          Caption = '2'
          OnClick = N28Click
        end
        object N33: TMenuItem
          Caption = '3'
          OnClick = N33Click
        end
        object N43: TMenuItem
          Caption = '4'
          OnClick = N43Click
        end
        object N53: TMenuItem
          Caption = '5'
          OnClick = N53Click
        end
      end
    end
    object Tools1: TMenuItem
      Caption = 'Tools'
      object CalculateAvgCyclesperInstruction1: TMenuItem
        Caption = 'Calculate Avg. Cycles per Instruction'
        OnClick = CalculateAvgCyclesperInstruction1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object GenerateTASMTable1: TMenuItem
        Caption = 'Generate TASM Table'
        OnClick = GenerateTASMTable1Click
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object Options1: TMenuItem
        Caption = 'Options'
      end
    end
    object Open3: TMenuItem
      Caption = 'Tools'
      object Directory1: TMenuItem
        Caption = 'Open working-directory'
        OnClick = Button30Click
      end
      object Hexeditor1: TMenuItem
        Caption = 'Hex editor'
        OnClick = Button32Click
      end
      object Programmer1: TMenuItem
        Caption = 'Programmer'
        OnClick = Button15Click
      end
      object Commandprompt1: TMenuItem
        Caption = 'Command prompt'
        OnClick = Button18Click
      end
      object Calculator1: TMenuItem
        Caption = 'Calculator'
        OnClick = Button17Click
      end
      object Notepad1: TMenuItem
        Caption = 'Notepad'
        OnClick = Button1Click
      end
    end
    object COM1: TMenuItem
      Caption = 'COM Port'
      object Openport1: TMenuItem
        Caption = 'Open port'
      end
      object Closeport1: TMenuItem
        Caption = 'Close port'
      end
      object N23: TMenuItem
        Caption = '-'
      end
      object Clearterminal1: TMenuItem
        Caption = 'Clear terminal'
      end
      object N24: TMenuItem
        Caption = '-'
      end
      object Sendfile1: TMenuItem
        Caption = 'Send file'
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'All files (*.*)|*.*|Assembly (*.asm)|*.asm|Text (*.txt)|*.txt'
    Title = 'Save As'
    Left = 792
    Top = 344
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 728
    Top = 288
  end
  object PopupMenu4: TPopupMenu
    Left = 576
    Top = 344
    object Sorted1: TMenuItem
      Caption = 'Sorted'
      Checked = True
      OnClick = Sorted1Click
    end
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 760
    Top = 288
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    TerminateWaitTime = 5000000
    OnCommandGet = IdHTTPServer1CommandGet
    AutoStartSession = True
    Left = 792
    Top = 288
  end
  object telnet: TServerSocket
    Active = False
    Port = 51515
    ServerType = stNonBlocking
    OnClientConnect = telnetClientConnect
    OnClientRead = telnetClientRead
    Left = 224
    Top = 328
  end
end
