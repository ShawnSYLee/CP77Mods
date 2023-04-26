module VendorPreview.StoresManager
import VendorPreview.Utils.AtelierLog

public class VirtualAtelierStoresSystem extends ScriptableSystem {

  private let stores: array<ref<VirtualShop>>;
  private persistent let bookmarked: array<CName>;
  private persistent let prevStores: array<CName>;

  public static func GetInstance(gi: GameInstance) -> ref<VirtualAtelierStoresSystem> {
    let system: ref<VirtualAtelierStoresSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"VendorPreview.StoresManager.VirtualAtelierStoresSystem") as VirtualAtelierStoresSystem;
    return system;
  }

  public func GetStores() -> array<ref<VirtualShop>> {
    return this.stores;
  }

  public func SetStores(stores: array<ref<VirtualShop>>) -> Void {
    this.stores = stores;
  }

  public func AddBookmark(storeID: CName) -> Void {
    let current: array<CName> = this.bookmarked;
    ArrayPush(current, storeID);
    this.bookmarked = current;
    this.RefreshBookmarks();
  }

  public func RemoveBookmark(storeID: CName) -> Void {
    let current: array<CName> = this.bookmarked;
    ArrayRemove(current, storeID);
    this.bookmarked = current;
    this.RefreshBookmarks();
  }

  public func IsBookmarked(storeID: CName) -> Bool {
    return ArrayContains(this.bookmarked, storeID);
  }

  public func BuildStoresList() -> Void {
    ArrayClear(this.stores);

    let event: ref<VirtualShopRegistration> = new VirtualShopRegistration();
    event.SetSystemInstance(this);
    GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(event);
    AtelierLog("Initialized");
  }

  public func RefreshNewLabels() -> Void {
    let current: array<ref<VirtualShop>> = this.stores;
    let refreshed: array<ref<VirtualShop>>;
    let previousIds: array<CName> = this.prevStores;
    let id: CName;
    for store in current {
      id = store.storeID;
      store.isNew = !ArrayContains(previousIds, id) && ArraySize(previousIds) > 0 ;
      ArrayPush(refreshed, store);
    };
    this.stores = refreshed;
    this.prevStores = this.GetStoresIds();
  }

  private func RefreshBookmarks() -> Void {
    let newStores: array<ref<VirtualShop>>;
    let newStore: ref<VirtualShop>;
    for store in this.stores {
      newStore = store;
      newStore.isBookmarked = this.IsBookmarked(store.storeID);
      ArrayPush(newStores, newStore);
    };

    this.stores = newStores;
  }

  // For case when bookmarked stores uninstalled
  private func RefreshPersistedBookmarks() -> Void {
    let storeIds: array<CName>;
    for store in this.stores {
      ArrayPush(storeIds, store.storeID);
    };

    let actuallyBookmarked: array<CName>;
    for bookmark in this.bookmarked {
      if ArrayContains(storeIds, bookmark) {
        ArrayPush(actuallyBookmarked, bookmark);
      } else {
        AtelierLog(s"Installed store not found, persisted bookmark removed: \(bookmark)");
      };
    };

    this.bookmarked = actuallyBookmarked;
  }

  private func GetStoresIds() -> array<CName> {
    let result: array<CName>;
    for store in this.stores {
      ArrayPush(result, store.storeID);
    };

    return result;
  }
}

@wrapMethod(gameuiInGameMenuGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  VirtualAtelierStoresSystem.GetInstance(this.GetPlayerControlledObject().GetGame()).BuildStoresList();
}