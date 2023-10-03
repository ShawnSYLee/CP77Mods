import VendorPreview.Config.VirtualAtelierConfig
import VirtualAtelier.Helpers.CurrentPlayerZoneHelper
import VirtualAtelier.Core.AtelierTexts
import VirtualAtelier.Logs.AtelierLog

// Temp flag to show atelier tab content
// TODO Need a better way to inject, research why LoadWebPage does not work with custom internet
@addField(BrowserController)
private let showAtelier: Bool;

@addMethod(BrowserController)
protected cb func OnShowAtelierEvent(evt: ref<ShowAtelierEvent>) -> Bool {
  this.showAtelier = evt.show;
}

public class ShowAtelierEvent extends Event {
  let show: Bool;

  public static func Create(show: Bool) -> ref<ShowAtelierEvent> {
    let self: ref<ShowAtelierEvent> = new ShowAtelierEvent();
    self.show = show;
    return self;
  }
}

@wrapMethod(ComputerInkGameController)
private final func ShowMenuByName(elementName: String) -> Void {
  if Equals(elementName, "atelier") {
    this.QueueEvent(ShowAtelierEvent.Create(true));
    let internetData: SInternetData = this.GetOwner().GetDevicePS().GetInternetData();
    this.GetMainLayoutController().ShowInternet(internetData.startingPage);
    this.RequestMainMenuButtonWidgetsUpdate();
    if NotEquals(elementName, "mainMenu") {
      this.GetMainLayoutController().MarkManuButtonAsSelected(elementName);
    };

    return ;
  };

  this.QueueEvent(ShowAtelierEvent.Create(false));
  wrappedMethod(elementName);
}

@wrapMethod(ComputerInkGameController)
private final func HideMenuByName(elementName: String) -> Void {
  if Equals(elementName, "atelier") {
    this.GetMainLayoutController().HideInternet();
    return; 
  };

  wrappedMethod(elementName);
}

// Add Atelier tab to PC layout
@wrapMethod(ComputerControllerPS)
public final func GetMenuButtonWidgets() -> array<SComputerMenuButtonWidgetPackage> {
  if !this.IsMenuEnabled(EComputerMenuType.MAIN) {
    return wrappedMethod();
  };

  let packages: array<SComputerMenuButtonWidgetPackage> = wrappedMethod();
  let config: ref<VirtualAtelierConfig> = VirtualAtelierConfig.Get();
  let package: SComputerMenuButtonWidgetPackage;
  let player: ref<PlayerPuppet> = this.GetLocalPlayerControlledGameObject() as PlayerPuppet;
  let isInSafeZone: Bool = CurrentPlayerZoneHelper.IsInSafeZone(player, config);
  if isInSafeZone {
    if this.IsMenuEnabled(EComputerMenuType.INTERNET) && ArraySize(packages) > 0 {
      package.widgetName = "atelier";
      package.displayName = AtelierTexts.TabName();
      package.ownerID = this.GetID();
      package.iconID = n"iconAtelier";
      package.widgetTweakDBID = this.GetMenuButtonWidgetTweakDBID();
      package.isValid = true;
      SWidgetPackageBase.ResolveWidgetTweakDBData(package.widgetTweakDBID, package.libraryID, package.libraryPath);
      ArrayPush(packages, package);
    };
  } else {
    AtelierLog("PC is in dangerous or restricted zone, Atelier tab was hidden");
  };

  return packages;
}


// Spawn Atelier stores widget
@addMethod(WebPage)
private func PopulateAtelierView() {
  let root: ref<inkCompoundWidget> = this.GetWidget(n"page/linkPanel/panel") as inkCompoundWidget;
  if (!IsDefined(root)) {
    root = this.GetWidget(n"Page/linkPanel/panel") as inkCompoundWidget;
  };
  root.RemoveAllChildren();
  this.SpawnFromExternal(root, r"base\\gameplay\\gui\\virtual_atelier_stores.inkwidget", n"AtelierStores:VirtualAtelier.UI.AtelierStoresListController");
}


// Switch Atelier tab icon
// ^^ kudos to NexusGuy999 for tab widget hack ^^
@wrapMethod(ComputerMenuButtonController)
public func Initialize(gameController: ref<ComputerInkGameController>, widgetData: SComputerMenuButtonWidgetPackage) -> Void {
  wrappedMethod(gameController, widgetData);

  if Equals(widgetData.widgetName, "atelier") {
    inkImageRef.SetTexturePart(this.m_iconWidget, n"logo_wdb_large");
    inkImageRef.SetAtlasResource(this.m_iconWidget, r"base\\gameplay\\gui\\fullscreen\\wardrobe\\atlas_wardrobe.inkatlas");
  };
}


// Show Atelier if tab was activated
@wrapMethod(BrowserController)
protected cb func OnPageSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
  wrappedMethod(widget, userData);

  let currentController: ref<WebPage>;
  if this.showAtelier {
    currentController = this.m_currentPage.GetController() as WebPage;
    inkTextRef.SetText(this.m_addressText, "NETdir://atelier.pub");
    currentController.PopulateAtelierView();
  };
}
