module VirtualAtelier.UI

public class AtelierStoresDataView extends ScriptableDataView {

  public func UpdateView() {
    this.EnableSorting();
    this.Sort();
    this.DisableSorting();
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftEntry: ref<VirtualShop> = left as VirtualShop;
    let rightEntry: ref<VirtualShop> = right as VirtualShop;

    if NotEquals(leftEntry.bookmarked, rightEntry.bookmarked) {
      if leftEntry.bookmarked {
        return true;
      } else {
        return false;
      };
    };
    
    return StrCmp(leftEntry.storeName, rightEntry.storeName) < 0;
  }
}
