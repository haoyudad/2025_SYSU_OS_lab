#include "bitmap.h"
#include "stdlib.h"
#include "stdio.h"
#include <climits>

BitMap::BitMap()
{
}

void BitMap::initialize(char *bitmap, const int length)
{
    this->bitmap = bitmap;
    this->length = length;

    int bytes = ceil(length, 8);

    for (int i = 0; i < bytes; ++i)
    {
        bitmap[i] = 0;
    }
}

bool BitMap::get(const int index) const
{
    int pos = index / 8;
    int offset = index % 8;

    return (bitmap[pos] & (1 << offset));
}

void BitMap::set(const int index, const bool status)
{
    int pos = index / 8;
    int offset = index % 8;

    // 清0
    bitmap[pos] = bitmap[pos] & (~(1 << offset));

    // 置1
    if (status)
    {
        bitmap[pos] = bitmap[pos] | (1 << offset);
    }
}

int BitMap::allocate(const int count) {
    if (count <= 0 || count > length) {
        return -1;
    }

    int best_start = -1;
    int best_size = INT_MAX;
    int index = 0;

    // 遍历整个位图
    while (index < length) {
        // 跳过已分配的块
        while (index < length && get(index)) {
            ++index;
        }

        if (index >= length) {
            break;
        }

        // 记录当前空闲块的起始位置和大小
        int start = index;
        int current_size = 0;

        // 统计连续空闲块的大小
        while (index < length && !get(index)) {
            ++current_size;
            ++index;
        }

        // 更新最佳块（满足需求且更小）
        if (current_size >= count && current_size < best_size) {
            best_start = start;
            best_size = current_size;
        }
    }

    // 分配最佳块（遍历完成后统一处理）
    if (best_start != -1) {
        for (int i = 0; i < count; ++i) {
            set(best_start + i, true);
        }
        return best_start;
    }

    return -1;
}

void BitMap::release(const int index, const int count)
{
    for (int i = 0; i < count; ++i)
    {
        set(index + i, false);
    }
}

char *BitMap::getBitmap()
{
    return (char *)bitmap;
}

int BitMap::size() const
{
    return length;
}
